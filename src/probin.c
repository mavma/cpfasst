#include "probin.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void get_problem_parameters(char *fname, double* Tfin, int* nsteps, double* lam1, double* lam2) {
    FILE *f;
    char *line = NULL;
    size_t len = 0;
    ssize_t read;

    if(!(f = fopen(fname, "r"))) {
        printf("Error while opening input file\n"); exit(EXIT_FAILURE);
    }
    while((read = getline(&line, &len, f)) != EOF) {
        if(sscanf(line, " Tfin = %lf", Tfin) == 1) continue;
        else if(sscanf(line, " nsteps = %d", nsteps) == 1) continue;
        else if(sscanf(line, " lam1 = %lf", lam1) == 1) continue;
        else if(sscanf(line, " lam2 = %lf", lam2) == 1) continue;
    }
    fclose(f);
    if (line)
        free(line);
}