#pragma once
#include <string>
#include <vector>
#include <stdarg.h>
#include <sys/types.h>

using namespace std;

ssize_t write_all(int fd, const void* buf, size_t n);
void wputs(int fd, const char* s);
void wprint(int fd, const char* s);
int parse_tokens(const char* line, vector<string>& out);
string fmt(const char* tpl, ...);
