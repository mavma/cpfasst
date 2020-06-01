#pragma once

#include <stddef.h>

#define calloc_and_check(count,size) calloc_and_check_(count, size, __FILE__, __LINE__)
#define stop(...) stop_(__FILE__, __LINE__, __VA_ARGS__)

void* calloc_and_check_(int count, size_t size, const char* file, int nline);
void stop_(const char* file, int nline, const char *fmt, ...);