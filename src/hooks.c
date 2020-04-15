#include "hooks.h"

#include <stdio.h>

void my_custom_hook(void* pfasst, int* idx) {
    printf("called for level %d\n", *idx);
}
