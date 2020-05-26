// This is a rudimentary nml parser, used to facilitate running the cpfasst examples with the
// same problem-specific parameters as their LibPFASST counterparts for testing. When adapting
// the example for a different use, any type of parser (xml, command line, fixed parameters, etc)
// may be substituted.

#include "probin.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "local.h"

void load_local_parameters(char *fname) {
    FILE *f;
    if(!(f = fopen(fname, "r"))) {
        printf("Error opening input file %s\n", fname); exit(EXIT_FAILURE);
    }

    // reset to default values
    local_prm.nsteps = -1;
    local_prm.lam1 = 1.0;
    local_prm.lam2 = -2.0;
    local_prm.dt = 0.01;
    local_prm.Tfin = 1.0;
    strcpy(local_prm.pfasst_nml, fname);

    char *line = NULL;
    size_t len = 0;
    ssize_t read;
    while((read = getline(&line, &len, f)) != EOF) {
        if(sscanf(line, " lam1 = %lf", &local_prm.lam1) == 1) continue;
        else if(sscanf(line, " lam2 = %lf", &local_prm.lam2) == 1) continue;
        else if(sscanf(line, " dt = %lf", &local_prm.dt) == 1) continue;
        else if(sscanf(line, " Tfin = %lf", &local_prm.Tfin) == 1) continue;
        else if(sscanf(line, " nsteps = %d", &local_prm.nsteps) == 1) continue;
        else if(sscanf(line, " pfasst_nml = %s", local_prm.pfasst_nml) == 1) continue;
    }
    fclose(f);
    if (line)
        free(line);

    // reset dt if Tfin is set
    if (local_prm.Tfin > 0.0) local_prm.dt = local_prm.Tfin/local_prm.nsteps;
}