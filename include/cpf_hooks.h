#pragma once

#include <cpf_static.h>

/*
 * Type:  cpf_hook_cb_t
 * --------------------
 * Typedef for user-defined hook callbacks
 *  pf: opaque data structure which MUST NOT BE MODIFIED. If access to pfasst parameters is needed, use
 *      cpf_get_parameters
 *  idx: pointer to 1-based index of level which triggered the callback
 */
typedef void(cpf_hook_cb_t)(void* pf, int* idx)

/*
 * Function:  cpf_add_custom_hook
 * --------------------
 * Adds a custom hook to a user-defined callback function
 *
 *  level_index: pointer to 1-based index of level to add the hook for. Set value to -1 to add for all levels.
 *  hook: which type of hook to add
 *  callback: double pointer to user-defined callback function
 */
void cpf_add_custom_hook(int* level_index, cpf_hooks_t* hook, cpf_hook_cb_t **callback);