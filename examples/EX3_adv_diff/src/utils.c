#include "utils.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <mpi.h>

void* malloc_and_check_(size_t size, const char* file, int nline) {
    void* ptr = malloc(size);
    if(!ptr) {
        stop("Allocation error", file, nline);
    }
    return ptr;
}

void stop_(const char* file, int nline, const char *fmt, ...) {
    fprintf(stderr, "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
    fprintf(stderr, "CPFASST execution has stopped!\n");
    fprintf(stderr, "File: %s\n", file);
    fprintf(stderr, "Line number:  %d\n", nline);
    va_list argp;
    va_start(argp, fmt);
    vfprintf(stderr, fmt, argp);
    va_end(argp);
    fprintf(stderr, "\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
    exit(EXIT_FAILURE);
}

void debug_log(const char *fmt, ...) {
    int np, rank;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &np);
    char logfile[16]; sprintf(logfile, "log%04d", rank);
    FILE *f = (np == 1) ? stdout : fopen(logfile, "a");
    va_list argp;
    va_start(argp, fmt);
    vfprintf(f, fmt, argp);
    va_end(argp);
    if(np != 1) fclose(f);
}