CC = gcc
CFLAGS = -O2 -Wall -Wextra -Werror -std=c11 -Iinclude
BIN_DIR = bin
SRC_DIR = src

all: $(BIN_DIR)/io_optimizer

check: all
	bash ./scripts/check.sh

grade: all
	bash ./scripts/grade.sh

$(BIN_DIR)/io_optimizer: $(SRC_DIR)/io_optimizer.c include/io_optimizer.h
	mkdir -p $(BIN_DIR)
	$(CC) $(CFLAGS) $< -o $@

clean:
	rm -f $(BIN_DIR)/io_optimizer \
		tests/output_byte.txt \
		tests/output_block.txt \
		tests/report_byte.txt \
		tests/report_block.txt

.PHONY: all check grade clean
