#include "common.hpp"
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>

using namespace std;

ssize_t write_all(int fd, const void* buf, size_t n) {
    const char* p = (const char*)buf;
    size_t left = n;
    while (left > 0) {
        ssize_t k = write(fd, p, left);
        if (k < 0) {
            if (errno == EINTR) continue;
            return k;
        }
        left -= (size_t)k;
        p += k;
    }
    return (ssize_t)n;
}

void wputs(int fd, const char* s) {
    if (!s) return;
    write_all(fd, s, strlen(s));
    write_all(fd, "\n", 1);
}

void wprint(int fd, const char* s) {
    if (!s) return;
    write_all(fd, s, strlen(s));
}

int parse_tokens(const char* line, vector<string>& out) {
    out.clear();
    const char* p = line;
    while (*p) {
        while (*p==' '||*p=='\t'||*p=='\r'||*p=='\n') ++p;
        if (!*p) break;
        const char* start = p;
        while (*p && *p!=' ' && *p!='\t' && *p!='\r' && *p!='\n') ++p;
        out.emplace_back(start, p - start);
    }
    return (int)out.size();
}

string fmt(const char* tpl, ...) {
    char buf[1024];
    va_list ap; va_start(ap, tpl);
    vsnprintf(buf, sizeof(buf), tpl, ap);
    va_end(ap);
    return string(buf);
}
