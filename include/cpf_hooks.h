#pragma once

#include <cpf_static.h>

// Typedef for user-defined hook callback functions
//   *pf: opaque data structure which MUST NOT BE MODIFIED
//   *level_index: index of level which triggered the callback
typedef void(*cpf_hook_cb_t)(void* pf, int* level_index);

// Add a custom hook to a level for a certain condition, triggering a call to a user-defined callback function
// Use level_index = -1 to set for all levels.
void cpf_add_custom_hook(int level_index, cpf_hooks_t hook, cpf_hook_cb_t callback);

// Can be called from a hook callback to set the error value for a level at the current run state
void cpf_set_error(int level_index, double error);