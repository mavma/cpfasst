#pragma once

#include <stddef.h>

#define cpf_calloc_and_check(count,size) calloc_and_check(count, size, __FILE__, __LINE__)
#define cpf_stop(msg) stop(msg, __FILE__, __LINE__)

void* calloc_and_check(int count, size_t size, const char* file, int nline);
void stop(const char* msg, const char* file, int nline);