/** @file cpf_hooks.h
 * C interfaces to functions allowing creation of custom hooks
 */

#pragma once
#include <cpf_static.h>

/**
 * Required signature for hook callback functions
 * @param pf Opaque data, do not dereference
 * @param[in] level_index Index (1-based) of the level
 */
typedef void(*cpf_hook_cb_t)(void* pf, int* level_index);

/**
 * Add a custom hook to a level for the given condition
 * @param[in] level_index Index (1-based) of the level, value -1 sets hook for all levels
 * @param[in] hook Condition for invoking the callback
 * @param[in] callback Callback function
 */
void cpf_add_custom_hook(int level_index, cpf_hooks_t hook, cpf_hook_cb_t callback);

