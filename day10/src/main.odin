package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:slice"

OpCode :: enum {
	empty,
	noop,
	addx,
}
Op :: struct {
	code: OpCode,
	val:  int,
}

main :: proc() {
	//data, ok := os.read_entire_file_from_filename("sample.txt")
	data, ok := os.read_entire_file_from_filename("input.txt")
	if !ok {panic("cannot read file")}
	defer delete(data)

	ops := [dynamic]Op{}
	defer delete(ops)

	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		cmd := strings.fields(line)
		defer delete(cmd)

		switch (cmd[0]) {
		case "noop":
			append(&ops, Op{.noop, 0})
		case "addx":
			append(&ops, Op{.addx, strconv.atoi(cmd[1])})
		}
	}

	regx := 1
	cycle := 0
    signal_strength := 0
    calc_signal_at := [?]int{20, 60, 100, 140, 180, 220}
	cycle_rem := 0
	cur_op := Op{}

	for cycle := 1; len(ops) > 0 || cur_op.code != .empty; cycle += 1 {
		if cur_op.code == .empty {
			cur_op = pop_front(&ops)
			cycle_rem = 1 if cur_op.code == .noop else 2
		}

        // do the cycle
        cycle_rem -= 1

        // calculate signal strength?
        if slice.any_of(calc_signal_at[:], cycle) {
            signal_strength += cycle * regx
        }

        // are we done?
		if cycle_rem == 0 {
			// finished op
			regx += cur_op.val
            cur_op = Op{}
		}
	}

    fmt.println("reg x:", regx, "signal strength:", signal_strength)
}
