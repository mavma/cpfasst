#pragma once

// Forward declaration of Fortran routines
void cpf_probin_init();
void cpf_mpi_create();
void cpf_pfasst_create();
void cpf_user_obj_allocate(size_t* data_size);
void cpf_pfasst_setup();
void cpf_add_hook();
void cpf_print_loc_options();
void cpf_setup_ic();
void cpf_pfasst_run();
void cpf_cleanup();

void set_fname(char*);

void cpf_imex_sweeper_set_feval(void*);
void cpf_imex_sweeper_set_fcomp(void*);