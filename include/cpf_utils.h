#pragma once

#include <stdio.h>
#include <stdlib.h>

#define cpf_calloc_and_check(count,size) calloc_and_check(count, size, __FILE__, __LINE__)
#define cpf_stop(msg) stop(msg, __FILE__, __LINE__)

// TODO: compile separately

void stop(const char* msg, const char* file, int nline);
void* calloc_and_check(int count, size_t size, const char* file, int nline);

void* calloc_and_check(int count, size_t size, const char* file, int nline) {
    void* ptr = calloc(count, size);
    if(!ptr) {
        stop("Allocation error", file, nline);
    }
    return ptr;
}

void stop(const char* msg, const char* file, int nline) {
    printf("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
    printf("CPFASST execution has stopped!\n");
    printf("File: %s\n", file);
    printf("Line number:  %d\n", nline);
    if(msg) printf("%s\n", msg);
    printf("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
    exit(EXIT_FAILURE);
}
