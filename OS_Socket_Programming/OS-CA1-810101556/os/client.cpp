#include "common.hpp"
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/select.h>

using namespace std;

int main(int argc, char** argv){
    if(argc<3){ wputs(2,"Usage: client <server_ip> <port>"); return 1; }
    const char* ip=argv[1]; int port=atoi(argv[2]);

    int s=socket(AF_INET,SOCK_STREAM,0);
    sockaddr_in a{}; a.sin_family=AF_INET; a.sin_port=htons(port);
    inet_pton(AF_INET,ip,&a.sin_addr);
    if(connect(s,(sockaddr*)&a,sizeof(a))<0){ wputs(2,"connect failed"); return 1; }

    wputs(1,"Connected. Type commands, Ctrl+D to exit.");
    char buf[1024]; fd_set rfds; int maxfd=s>0?s:0;

    while(1){
        FD_ZERO(&rfds); FD_SET(0,&rfds); FD_SET(s,&rfds);
        if(select(maxfd+1,&rfds,nullptr,nullptr,nullptr)<0) break;

        if(FD_ISSET(0,&rfds)){
            ssize_t n=read(0,buf,sizeof(buf));
            if(n<=0) break;
            send(s,buf,n,0);
        }
        if(FD_ISSET(s,&rfds)){
            ssize_t n=recv(s,buf,sizeof(buf)-1,0);
            if(n<=0) break;
            buf[n]=0; wprint(1,buf);
        }
    }
    close(s);
    return 0;
}
