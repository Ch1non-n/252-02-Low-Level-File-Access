#ifndef IO_OPTIMIZER_H
#define IO_OPTIMIZER_H

#include <stddef.h>

typedef struct {
    long long bytes;
    long long read_calls;
    long long write_calls;
    long long elapsed_us;
} metrics_t;

int parse_block_size(const char *text, size_t *out_block_size);
int copy_with_metrics(const char *input_path, const char *output_path, size_t block_size, metrics_t *m);
void print_metrics(const metrics_t *m);

#endif
