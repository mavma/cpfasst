#pragma once

#include <stddef.h>

#define malloc_and_check(size) malloc_and_check_(size, __FILE__, __LINE__)
#define stop(...) stop_(__FILE__, __LINE__, __VA_ARGS__)

void* malloc_and_check_(size_t size, const char* file, int nline);
void stop_(const char* file, int nline, const char *fmt, ...);
void debug_log(const char *fmt, ...);