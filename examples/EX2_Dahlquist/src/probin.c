// This is a rudimentary nml parser, used to facilitate running the cpfasst examples with the
// same problem-specific parameters as their LibPFASST counterparts for testing. When adapting
// the example for a different use, it's recommended to replace nml input by a C-friendly format

#include "probin.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

bool try_parse_nml(char* line, char* name, char* format, void* storage) {
    char format_tmp[64];
    sprintf(format_tmp, " %s = %%%s", name, format);
    if(sscanf(line, format_tmp, storage) == 1) return true;
    else return false;
}

ex2_prm_t load_local_parameters(char* nml_path) {
    FILE *f;
    if(!(f = fopen(nml_path, "r"))) {
        printf("Error opening input file %s\n", nml_path); exit(EXIT_FAILURE);
    }

    ex2_prm_t prm;
    prm.nsteps = -1;
    prm.lam1 = 1.0;
    prm.lam2 = -2.0;
    prm.dt = 0.01;
    prm.Tfin = 1.0;
    strcpy(prm.pfasst_nml, nml_path);

    char *line = NULL;
    size_t len = 0;
    while(getline(&line, &len, f) != EOF) {
        if(try_parse_nml(line,      "lam1", "lf", &prm.lam1)) continue;
        else if(try_parse_nml(line, "lam2", "lf", &prm.lam2)) continue;
        else if(try_parse_nml(line, "dt",   "lf", &prm.dt)) continue;
        else if(try_parse_nml(line, "Tfin", "lf", &prm.Tfin)) continue;
        else if(try_parse_nml(line, "nsteps", "d", &prm.nsteps)) continue;
        else if(try_parse_nml(line, "pfasst_nml", "s", &prm.pfasst_nml)) continue;
    }

    fclose(f);
    if (line) free(line);
    if (prm.Tfin > 0.0) prm.dt = prm.Tfin / prm.nsteps; // reset dt if Tfin is set

    return prm;
}