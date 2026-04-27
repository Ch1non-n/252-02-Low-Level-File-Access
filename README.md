# Assignment: Syscall Sprint (Space and Time Optimization)

## Concept

You will implement a low-level file copy tool using POSIX syscalls and measure both:

- Space usage idea: bounded buffer size (memory footprint)
- Time usage idea: fewer syscalls and better runtime

This assignment highlights why C can be fast for system-level tasks and gives a clean way to compare C with other languages later.

## Learning Goals

- Practice `open`, `read`, `write`, and `close`
- Understand how block size affects syscall count and speed
- Produce deterministic metrics suitable for GitHub autograding

## Repository Layout

- `src/`: student starter implementation
- `include/`: shared type and function declarations
- `bin/`: build outputs
- `samples/`: static sample input for manual runs
- `scripts/`: local check and grading hooks
- `tests/`: visible tests and deterministic grader data

## Task

Complete all `TODO(student)` blocks in `src/io_optimizer.c`.

Program usage:

```bash
./bin/io_optimizer <input_file> <output_file> <block_size>
```

Rules:

- Use low-level file I/O (`open/read/write/close`), not stdio copy helpers
- `block_size` must be between `1` and `4096`
- Program must print exactly these 4 lines:

```text
bytes=<number>
read_calls=<number>
write_calls=<number>
elapsed_us=<number>
```

Definitions used by tests:

- `bytes`: total bytes copied
- `read_calls`: number of times `read()` is called, including final `read()` returning `0` at EOF
- `write_calls`: number of times `write()` is called
- `elapsed_us`: elapsed wall-clock time in microseconds for copy loop

## Why This Is an Optimization Assignment

- `block_size=1` behaves like byte-by-byte copy: tiny memory, many syscalls
- Larger `block_size` uses more memory but far fewer syscalls and usually better speed
- You can compare this C implementation to Python/Java/Rust later using the same input and same metric format

## Autograding (GitHub Classroom Friendly)

The grader uses a single static input file and deterministic checks.

Build locally:

```bash
cd 02-low-level-file-access-template
make
```

Run locally:

```bash
cd 02-low-level-file-access-template
./bin/io_optimizer samples/input.txt tests/manual_output.txt 256
```

Autograder check:

```bash
make check
```

## Submission Checklist
- builds with no warnings (`-Wall -Wextra -Werror`)
- `make check` passes
- all `TODO(student)` blocks are replaced with working code
