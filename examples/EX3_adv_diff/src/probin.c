// This is a rudimentary nml parser, used to facilitate running the cpfasst examples with the
// same problem-specific parameters as their LibPFASST counterparts for testing. When adapting
// the example for a different use, it's recommended to replace nml input by a C-friendly format

#include "probin.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include "utils.h"
#include "shared.h"

bool try_parse_nml(char* line, char* name, char* format, void* storage) {
    char format_tmp[64];
    sprintf(format_tmp, " %s = %%%s", name, format);
    if(sscanf(line, format_tmp, storage) == 1) return true;
    else return false;
}

bool try_parse_nml_int_arr(char* line, char* name, int* storage, int max_length) {
    char format_tmp[64];
    sprintf(format_tmp, " %s = %%d%%n", name);
    int read, pos = 0;
    if (sscanf(line, format_tmp, &storage[0], &read) != 1) return false;
    for (int i = 1; i < max_length; i++) {
        pos += read;
        if (sscanf(&line[pos], " %d%n", &storage[i], &read) != 1) break;
    }
    return true;
}

void load_local_parameters(char *fname) {
    FILE *f = fopen(fname, "r");
    if(!f) {
        stop("Cannot open input file %s", fname);
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
    int nx_pos;
    while((read = getline(&line, &len, f)) != EOF) {
        if(try_parse_nml(line, "v", "lf", &local_prm.v)) continue;
        else if(try_parse_nml(line, "nu", "lf", &local_prm.nu)) continue;
        else if(try_parse_nml(line, "kfreq", "lf", &local_prm.kfreq)) continue;
        else if(try_parse_nml(line, "dt", "lf", &local_prm.dt)) continue;
        else if(try_parse_nml(line, "Tfin", "lf", &local_prm.Tfin)) continue;
        else if(try_parse_nml(line, "Lx", "lf", &local_prm.Lx)) continue;
        else if(try_parse_nml(line, "nsteps", "d", &local_prm.nsteps)) continue;
        else if(try_parse_nml(line, "imex_stat", "d", &local_prm.imex_stat)) continue;
        else if(try_parse_nml(line, "ic_type", "d", &local_prm.ic_type)) continue;
        else if(try_parse_nml(line, "pfasst_nml", "s", &local_prm.pfasst_nml)) continue;
        else if(try_parse_nml_int_arr(line, "nx", local_prm.nx, PF_MAXLEVS)) continue;
    }

    fclose(f);
    if (line) free(line);

    if (local_prm.Tfin > 0.0) local_prm.dt = local_prm.Tfin/local_prm.nsteps; // reset dt if Tfin is set
    if (local_prm.ic_type != 1) stop("ic_type %d invalid or not implemented", local_prm.ic_type);
}