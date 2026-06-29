#include "common.hpp"
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <signal.h>
#include <time.h>
#include <unordered_map>
#include <vector>
#include <string>
#include <algorithm>
#include <errno.h>
#include <stdlib.h>
#include <utility>

using namespace std;

static const int TCP_PORT = 5050;
static const int UDP_BCAST_PORT = 5051;
static volatile sig_atomic_t g_tick = 0;
static void on_alarm(int){ g_tick = 1; }

enum SeatState { FREE = 0, TEMP = 1, CONFIRMED = 2 };

struct User { string username, password, role; };

struct Flight {
    string id, origin, destination, timeiso;
    int cols = 0, rows = 0;
    unordered_map<string,int> seat_state;
};

struct Reservation {
    int id = 0;
    string flight_id, username;
    vector<string> seats;
    string status;
    time_t expires_at = 0;
};

static unordered_map<string,User> g_users;
static unordered_map<string,Flight> g_flights;
static unordered_map<int,Reservation> g_resv;
static int g_next_resv_id = 1;

static int make_tcp_listener(int port){
    int s = socket(AF_INET, SOCK_STREAM, 0);
    int on = 1; setsockopt(s, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on));
    sockaddr_in a{}; a.sin_family = AF_INET; a.sin_port = htons(port); a.sin_addr.s_addr = INADDR_ANY;
    bind(s, (sockaddr*)&a, sizeof(a));
    listen(s, 128);
    return s;
}

static int make_udp_bcast(int port){
    int s = socket(AF_INET, SOCK_DGRAM, 0);
    int on = 1; setsockopt(s, SOL_SOCKET, SO_BROADCAST, &on, sizeof(on));
    sockaddr_in a{}; a.sin_family = AF_INET; a.sin_port = htons(port); a.sin_addr.s_addr = INADDR_ANY;
    bind(s, (sockaddr*)&a, sizeof(a));
    return s;
}

static void send_broadcast(int udp, const string& msg){
    sockaddr_in to{}; to.sin_family = AF_INET; to.sin_port = htons(UDP_BCAST_PORT); to.sin_addr.s_addr = inet_addr("255.255.255.255");
    sendto(udp, msg.c_str(), msg.size(), 0, (sockaddr*)&to, sizeof(to));
}

static string seat_name(int col, int row){
    char c = 'A' + col;
    return fmt("%c%d", c, row);
}

static void ensure_seats(Flight& f){
    for (int c = 0; c < f.cols; c++){
        for (int r = 1; r <= f.rows; r++){
            auto s = seat_name(c, r);
            if (!f.seat_state.count(s)) f.seat_state[s] = FREE;
        }
    }
}

static void expire_reservations(){
    time_t now = time(nullptr);
    vector<int> del;
    for (auto& kv : g_resv){
        auto& r = kv.second;
        if (r.status == "TEMPORARY" && r.expires_at <= now){
            Flight& f = g_flights[r.flight_id];
            for (auto& s : r.seats) f.seat_state[s] = FREE;
            del.push_back(r.id);
        }
    }
    for (int id : del) g_resv.erase(id);
}

struct Client { int fd; string username, role, partial; };
static unordered_map<int,Client> g_clients;

static void reply(int fd, const string& s){
    string m = s;
    if (m.empty() || m.back() != '\n') m.push_back('\n');
    wprint(fd, m.c_str());
}

static void handle_cmd(int udp, Client& cli, const vector<string>& t){
    if (t.empty()) return;

    if (t[0] == "REGISTER" && t.size() == 4){
        if (g_users.count(t[2])){ reply(cli.fd, "ERROR UsernameAlreadyExists"); return; }
        g_users[t[2]] = User{t[2], t[3], t[1]};
        reply(cli.fd, "REGISTERED OK");
        send_broadcast(udp, fmt("BROADCAST NEW_USER %s %s", t[2].c_str(), t[1].c_str()));
        return;
    }

    if (t[0] == "LOGIN" && t.size() == 3){
        auto it = g_users.find(t[1]);
        if (it == g_users.end()){ reply(cli.fd, "ERROR UserNotFound"); return; }
        if (it->second.password != t[2]){ reply(cli.fd, "ERROR InvalidPassword"); return; }
        cli.username = it->second.username;
        cli.role = it->second.role;
        reply(cli.fd, "LOGIN OK");
        return;
    }

    if (t[0] == "ADD_FLIGHT" && t.size() == 7){
        if (cli.role != "AIRLINE"){ reply(cli.fd, "ERROR NotAirline"); return; }
        if (g_flights.count(t[1])){ reply(cli.fd, "ERROR DuplicateFlightID"); return; }
        Flight f; f.id = t[1]; f.origin = t[2]; f.destination = t[3]; f.timeiso = t[4];
        f.cols = atoi(t[5].c_str()); f.rows = atoi(t[6].c_str());
        ensure_seats(f);
        g_flights[f.id] = move(f);
        reply(cli.fd, "FLIGHT_ADDED OK");
        auto& ff = g_flights[t[1]];
        send_broadcast(udp, fmt("BROADCAST NEW_FLIGHT %s %s %s %s", ff.id.c_str(), ff.origin.c_str(), ff.destination.c_str(), ff.timeiso.c_str()));
        return;
    }

    if (t[0] == "LIST_FLIGHTS"){
        for (auto& kv : g_flights){
            auto& f = kv.second;
            ensure_seats(f);
            int freec = 0, total = 0;
            for (auto& s : f.seat_state){ total++; if (s.second == FREE) freec++; }
            reply(cli.fd, fmt("FLIGHT %s %s %s %s SEATS_AVAILABLE=%d/%d",
                              f.id.c_str(), f.origin.c_str(), f.destination.c_str(), f.timeiso.c_str(), freec, total));
        }
        return;
    }

    if (t[0] == "RESERVE" && t.size() >= 3){
        if (cli.username.empty()){ reply(cli.fd, "ERROR NotLoggedIn"); return; }
        auto it = g_flights.find(t[1]);
        if (it == g_flights.end()){ reply(cli.fd, "ERROR FlightNotFound"); return; }
        Flight& f = it->second;
        ensure_seats(f);
        for (size_t i = 2; i < t.size(); ++i){
            if (!f.seat_state.count(t[i]) || f.seat_state[t[i]] != FREE){ reply(cli.fd, "ERROR SeatUnavailable"); return; }
        }
        int id = g_next_resv_id++;
        Reservation r; r.id = id; r.flight_id = t[1]; r.username = cli.username; r.status = "TEMPORARY"; r.expires_at = time(nullptr) + 30;
        for (size_t i = 2; i < t.size(); ++i){ r.seats.push_back(t[i]); f.seat_state[t[i]] = TEMP; }
        g_resv[id] = move(r);
        reply(cli.fd, fmt("RESERVED TEMP %d EXPIRES_IN 30", id));
        return;
    }

    if (t[0] == "CONFIRM" && t.size() == 2){
        int id = atoi(t[1].c_str());
        auto it = g_resv.find(id);
        if (it == g_resv.end()){ reply(cli.fd, "ERROR ReservationExpired"); return; }
        if (it->second.status != "TEMPORARY" || it->second.expires_at < time(nullptr)){
            reply(cli.fd, "ERROR ReservationExpired");
            g_resv.erase(it);
            return;
        }
        it->second.status = "CONFIRMED";
        Flight& f = g_flights[it->second.flight_id];
        for (auto& s : it->second.seats) f.seat_state[s] = CONFIRMED;
        reply(cli.fd, "CONFIRMATION OK");
        return;
    }

    if (t[0] == "CANCEL" && t.size() == 2){
        int id = atoi(t[1].c_str());
        auto it = g_resv.find(id);
        if (it != g_resv.end()){
            Flight& f = g_flights[it->second.flight_id];
            for (auto& s : it->second.seats) f.seat_state[s] = FREE;
            g_resv.erase(it);
            reply(cli.fd, "CANCELLED OK");
        } else {
            reply(cli.fd, "ERROR NotFound");
        }
        return;
    }

    reply(cli.fd, "ERROR UnknownCommand");
}

int main(){
    signal(SIGALRM, on_alarm);
    alarm(1);

    int ls  = make_tcp_listener(TCP_PORT);
    int udp = make_udp_bcast(UDP_BCAST_PORT);

    fd_set rfds;
    int maxfd = (ls > udp ? ls : udp);

    while (1){
        if (g_tick){
            expire_reservations();
            g_tick = 0;
            alarm(1);
        }

        FD_ZERO(&rfds);
        FD_SET(ls, &rfds);
        FD_SET(udp, &rfds);
        for (auto& kv : g_clients) FD_SET(kv.first, &rfds);

        int res = select(maxfd + 1, &rfds, nullptr, nullptr, nullptr);
        if (res < 0){
            if (errno == EINTR) continue;
            break;
        }

        if (FD_ISSET(ls, &rfds)){
            int cs = accept(ls, nullptr, nullptr);
            if (cs >= 0){
                if (cs > maxfd) maxfd = cs;
                g_clients[cs] = Client{cs, "", "", ""};
                wputs(cs, "WELCOME");
            }
        }

        vector<int> to_close;
        for (auto& kv : g_clients){
            int fd = kv.first;
            auto& cli = kv.second;
            if (FD_ISSET(fd, &rfds)){
                char buf[1024];
                ssize_t n = recv(fd, buf, sizeof(buf) - 1, 0);
                if (n <= 0){ to_close.push_back(fd); continue; }
                buf[n] = 0;
                cli.partial.append(buf);
                size_t pos;
                while ((pos = cli.partial.find('\n')) != string::npos){
                    string line = cli.partial.substr(0, pos);
                    cli.partial.erase(0, pos + 1);
                    vector<string> t;
                    parse_tokens(line.c_str(), t);
                    handle_cmd(udp, cli, t);
                }
            }
        }
        for (int fd : to_close){ close(fd); g_clients.erase(fd); }
    }
    return 0;
}
