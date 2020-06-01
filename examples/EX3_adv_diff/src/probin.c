// This is a rudimentary nml parser, used to facilitate running the cpfasst examples with the
// same problem-specific parameters as their LibPFASST counterparts for testing. When adapting
// the example for a different use, any type of parser (xml, command line, fixed parameters, etc)
// may be substituted.

#include "probin.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "shared.h"

void load_local_parameters(char *fname) {
    FILE *f;
    if(!(f = fopen(fname, "r"))) {
        printf("Error opening input file %s\n", fname); exit(EXIT_FAILURE);
    }

    local_prm.v = 1.0;
    local_prm.nu = 0.01;
    local_prm.kfreq = 1.0;
    local_prm.dt = 0.01;
    local_prm.Tfin = 0.0;
    local_prm.Lx = 1.0;
    local_prm.nsteps = -1;
    local_prm.imex_stat = 2;
    local_prm.ic_type = 1;
    strcpy(local_prm.pfasst_nml, fname);

    char *line = NULL;
    size_t len = 0;
    ssize_t read;
    while((read = getline(&line, &len, f)) != EOF) {
        if(sscanf(line, " v = %lf", &local_prm.v) == 1) continue;
        else if(sscanf(line, " nu = %lf", &local_prm.nu) == 1) continue;
        else if(sscanf(line, " kfreq = %lf", &local_prm.kfreq) == 1) continue;
        else if(sscanf(line, " dt = %lf", &local_prm.dt) == 1) continue;
        else if(sscanf(line, " Tfin = %lf", &local_prm.Tfin) == 1) continue;
        else if(sscanf(line, " Lx = %lf", &local_prm.Lx) == 1) continue;
        else if(sscanf(line, " nsteps = %d", &local_prm.nsteps) == 1) continue;
        else if(sscanf(line, " imex_stat = %d", &local_prm.imex_stat) == 1) continue;
        else if(sscanf(line, " ic_type = %d", &local_prm.ic_type) == 1) continue;
        else if(sscanf(line, " pfasst_nml = %s", local_prm.pfasst_nml) == 1) continue;
    }

    int nx[PF_MAXLEVS];     // number of grid points




    fclose(f);
    if (line)
        free(line);

    // reset dt if Tfin is set
    if (local_prm.Tfin > 0.0) local_prm.dt = local_prm.Tfin/local_prm.nsteps;
}