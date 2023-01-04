package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:slice"
import "core:strconv"
import "core:math"
import "core:mem"

Monkey :: struct {
	items:           [dynamic]int,
	op_desc:         []string,
	divisor:         int,
	true_target:     int,
	false_target:    int,
	num_inspections: int,
}

NUM_ROUNDS :: 10000
PRINT_ROUND := [?]int{1, 20, 1000, 2000, 3000, 4000, 5000, 6000, 10000}

main :: proc() {
	track: mem.Tracking_Allocator
	mem.tracking_allocator_init(&track, context.allocator)
	context.allocator = mem.tracking_allocator(&track)

	_main()

	for _, leak in track.allocation_map {
		fmt.printf("%v leaked %v bytes\n", leak.location, leak.size)
	}
	for bad_free in track.bad_free_array {
		fmt.printf("%v allocation %p was freed badly\n", bad_free.location, bad_free.memory)
	}
}

_main :: proc() {
	//data, ok := os.read_entire_file_from_filename("sample.txt")
	data, ok := os.read_entire_file_from_filename("input.txt")
	if !ok {panic("cannot read file")}
	defer delete(data)

	blocks := strings.split(string(data), "\n\n")
	defer delete(blocks)

	monkeys := make([dynamic]Monkey)
    defer {
        for m in monkeys {
            delete(m.items)
            delete(m.op_desc)
        }
        delete(monkeys)
    }

	for block in blocks {
		lines := strings.split_lines(block)
		defer delete(lines)

        res := strings.split_multi(strings.trim_space(lines[1]), {" ", ": ", ", "})
		items := slice.mapper(res[2:], strconv.atoi)
        delete(res)
		defer delete(items) // bc we're copying below

		_, _, desc := strings.partition(lines[2], "new = ")
		op_desc := strings.fields(desc)

		test_fields := strings.fields(lines[3])
		defer delete(test_fields)
		divisor := strconv.atoi(slice.last(test_fields))

		true_fields := strings.fields(lines[4])
		defer delete(true_fields)
		true_target := strconv.atoi(slice.last(true_fields))

		false_fields := strings.fields(lines[5])
		defer delete(false_fields)
		false_target := strconv.atoi(slice.last(false_fields))

		append(
			&monkeys,
			Monkey{slice.to_dynamic(items), op_desc, divisor, true_target, false_target, 0},
		)
	}


	monkey_lcm := monkeys[0].divisor
	for i := 1; i < len(monkeys); i += 1 {
		monkey_lcm = math.lcm(monkey_lcm, monkeys[i].divisor)
	}
	fmt.println("lcm:", monkey_lcm)

	for r := 0; r < NUM_ROUNDS; r += 1 {
		for m in &monkeys {
			for len(m.items) > 0 {
				item := pop_front(&m.items)
				item = do_op(m.op_desc, item)

				item %%= monkey_lcm
				if item %% m.divisor == 0 {
					append(&monkeys[m.true_target].items, item)
				} else {
					append(&monkeys[m.false_target].items, item)
				}
				m.num_inspections += 1
			}
		}

		// fmt.println("round", r)
		// for m, i in monkeys {
		// 	fmt.println("monkey", i, m.items)
		// }

		// if slice.any_of(PRINT_ROUND[:], r + 1) {
        //     fmt.println("round", r+1)
		// 	for m, i in monkeys {
		// 		fmt.println("monkey", i, "inpected items", m.num_inspections, "times")
		// 	}
		// }
	}


	inspections := slice.mapper(monkeys[:], proc(m: Monkey) -> int {return m.num_inspections})
    defer delete(inspections)
	slice.reverse_sort(inspections)
	fmt.println("monkey business:", inspections[0] * inspections[1])
}

do_op :: proc(desc: []string, old: int) -> int {
	a := old if desc[0] == "old" else strconv.atoi(desc[0])
	b := old if desc[2] == "old" else strconv.atoi(desc[2])

	switch (desc[1]) {
	case "*":
		return a * b
	case "+":
		return a + b
	case:
		fmt.printf("got op:", desc[1])
		panic("bad op")
	}
}
