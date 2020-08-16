// This is a rudimentary nml parser, used to facilitate running the cpfasst examples with the
// same problem-specific parameters as their LibPFASST counterparts for testing. When adapting
// the example for a different use, it's recommended to replace nml input by a C-friendly format

#include "probin.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "shared.h"

bool try_parse_nml(char* line, char* name, char* format, void* storage) {
    char format_tmp[64];
    sprintf(format_tmp, " %s = %%%s", name, format);
    if(sscanf(line, format_tmp, storage) == 1) return true;
    else return false;
}

void load_local_parameters(char* nml_path) {
    FILE *f;
    if(!(f = fopen(nml_path, "r"))) {
        printf("Error opening input file %s\n", nml_path); exit(EXIT_FAILURE);
    }

    ex2_prm.nsteps = -1;
    ex2_prm.lam1 = 1.0;
    ex2_prm.lam2 = -2.0;
    ex2_prm.dt = 0.01;
    ex2_prm.Tfin = 1.0;
    strcpy(ex2_prm.pfasst_nml, nml_path);

    char *line = NULL;
    size_t len = 0;
    while(getline(&line, &len, f) != EOF) {
        if(try_parse_nml(line,      "lam1", "lf", &ex2_prm.lam1)) continue;
        else if(try_parse_nml(line, "lam2", "lf", &ex2_prm.lam2)) continue;
        else if(try_parse_nml(line, "dt",   "lf", &ex2_prm.dt)) continue;
        else if(try_parse_nml(line, "Tfin", "lf", &ex2_prm.Tfin)) continue;
        else if(try_parse_nml(line, "nsteps", "d", &ex2_prm.nsteps)) continue;
        else if(try_parse_nml(line, "pfasst_nml", "s", &ex2_prm.pfasst_nml)) continue;
    }

    fclose(f);
    if (line) free(line);
    if (ex2_prm.Tfin > 0.0) ex2_prm.dt = ex2_prm.Tfin / ex2_prm.nsteps; // reset dt if Tfin is set
}