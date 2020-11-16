//
// Created by matevz on 13.11.2020.
//

#include <iostream>

#include <stdlib.h>

#define TAG "MyHPVMExample"
#define LOGI(...)                                                              \
   ((void)__android_log_print(ANDROID_LOG_INFO, TAG, __VA_ARGS__))

#include "hpvm.h"

#define NON_STREAMING 0

#define ARRAY_SIZE 10


void sum_f(int *input, size_t bytes_input, int *sum, size_t bytes_sum) {
    __hpvm__hint(hpvm::CPU_TARGET);
    __hpvm__attributes(2, input, sum, 1, sum);

    void *self = __hpvm__getNode();
    long idx = __hpvm__getNodeInstanceID_x(self);

    *sum += input[idx];
}

void sum_f_wrapper(int *input, size_t bytes_input, int *sum, size_t bytes_sum) {
    __hpvm__hint(hpvm::CPU_TARGET);
    __hpvm__attributes(2, input, sum, 1, sum);

    void *node = __hpvm__createNodeND(1, sum_f, (size_t)ARRAY_SIZE);

    __hpvm__bindIn(node, 0, 0, NON_STREAMING);
    __hpvm__bindIn(node, 1, 1, NON_STREAMING);
    __hpvm__bindIn(node, 2, 2, NON_STREAMING);
    __hpvm__bindIn(node, 3, 3, NON_STREAMING);
}

void SumRoot(int *input, size_t bytes_input, int *sum, size_t bytes_sum) {
    __hpvm__hint(hpvm::CPU_TARGET);
    __hpvm__attributes(2, input, sum, 1, sum);

    void *sum_node = __hpvm__createNodeND(0, sum_f_wrapper);

    __hpvm__bindIn(sum_node, 0, 0, NON_STREAMING);
    __hpvm__bindIn(sum_node, 1, 1, NON_STREAMING);
    __hpvm__bindIn(sum_node, 2, 2, NON_STREAMING);
    __hpvm__bindIn(sum_node, 3, 3, NON_STREAMING);
}

typedef struct __attribute__((__packed__)) {
    int *input;
    size_t bytes_input;
    int *sum;
    size_t bytes_sum;
} RootIn;

__attribute__((used))
int hpvm_example_sum() {

    // Alloc arguments
    RootIn root_in = RootIn{};

    root_in.bytes_input = ARRAY_SIZE * sizeof(int);
    root_in.input = (int *)malloc(root_in.bytes_input*sizeof(int));

    root_in.bytes_sum = 1 * sizeof(int);
    root_in.sum = (int *)malloc(root_in.bytes_sum);
    *root_in.sum = 0;

    for (int i = 0; i < ARRAY_SIZE; i++) {
        root_in.input[i] = i + 1;
    }

    //
    //
    // HPVM
    //

    __hpvm__init();

    // Track memory
    llvm_hpvm_track_mem((void*)root_in.input, root_in.bytes_input);
    llvm_hpvm_track_mem((void*)root_in.sum, root_in.bytes_sum);

    void *sumDFG = __hpvm__launch(0, SumRoot, (void *)&root_in);
    __hpvm__wait(sumDFG);

    // Request sum
    llvm_hpvm_request_mem(root_in.sum, root_in.bytes_sum);

    __hpvm__cleanup();

    //
    // HPVM
    //
    //

    int result = *root_in.sum;

    // Free arguments
    free(root_in.input);
    free(root_in.sum);

    return result;
}
