package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:slice"
import "core:strconv"
import "core:math/big"

Monkey :: struct {
	items:           [dynamic]big.Int,
	op_desc:         []string,
	divisor:         big.Int,
	true_target:     int,
	false_target:    int,
	num_inspections: int,
}

NUM_ROUNDS :: 10000
REP_AFTER_ROUND := [?]int{1, 20, 1000, 2000, 3000, 4000, 10000}

main :: proc() {
	data, ok := os.read_entire_file_from_filename("sample.txt")
	//data, ok := os.read_entire_file_from_filename("input.txt")
	if !ok {panic("cannot read file")}
	defer delete(data)

	blocks := strings.split(string(data), "\n\n")
	defer delete(blocks)

	monkeys: [dynamic]Monkey

	for block in blocks {
		lines := strings.split_lines(block)
		defer delete(lines)

		// note: this leaks, I think
		items := slice.mapper(
			strings.split_multi(strings.trim_space(lines[1]), {" ", ": ", ", "})[2:],
			proc(s: string) -> big.Int {
				i := big.Int{}
				big.atoi(&i, s)
                as, _ := big.itoa(&i)
                defer delete(as)
                fmt.printf("turned %v into %v\n", s, as)
				return i
			},
		)
		defer delete(items) // bc slice.to_dynamic below

        fmt.print("items: ", len(items), items)
        for item in &items {
            as, _ := big.itoa(&item)
            defer delete(as)
            fmt.printf("%v ", as)
        }
        fmt.println()

		_, _, desc := strings.partition(lines[2], "new = ")
		op_desc := strings.fields(desc)

		test_fields := strings.fields(lines[3])
		defer delete(test_fields)
        divisor := big.Int{}
        big.atoi(&divisor, slice.last(test_fields))

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

	for m in monkeys {
		fmt.print("monkey items")
        for _, i in m.items {
            as, _ := big.itoa(&m.items[i])
            defer delete(as)
            fmt.printf("%v ", as)
        }
        fmt.println()
	}

	for r := 0; r < NUM_ROUNDS; r += 1 {
		for m in &monkeys {
			for len(m.items) > 0 {
				item := pop_front(&m.items)
				do_op(m.op_desc, &item)
                rem := &big.Int{}
                defer big.destroy(rem)
                
                big.int_mod(rem, &item, &m.divisor)
                zero, err := big.is_zero(rem)
                if err != nil {
                    fmt.println("error allocating while checking is_zero:", err)
                    panic("bad")
                }
				if zero {
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

		if slice.any_of(REP_AFTER_ROUND[:], r + 1) {
			fmt.println("round", r + 1)
			for m, i in monkeys {
				fmt.println("monkey", i, "inpected items", m.num_inspections, "times")
			}
		}

	}

	// for m, i in monkeys {
	// 	fmt.println("monkey", i, "inpected items", m.num_inspections, "times")
	// }

	inspections := slice.mapper(monkeys[:], proc(m: Monkey) -> int {return m.num_inspections})
	slice.reverse_sort(inspections)
	fmt.println("monkey business:", inspections[0] * inspections[1])
}

do_op :: proc(desc: []string, old: ^big.Int) {
	a, b := &big.Int{}, &big.Int{}
	defer big.destroy(a, b)

	if desc[0] == "old" {
		big.copy(a, old)
	} else {
		big.atoi(a, desc[0])
	}

	if desc[2] == "old" {
		big.copy(b, old)
	} else {
		big.atoi(b, desc[2])
	}

	switch (desc[1]) {
	case "*":
		big.int_mul(old, a, b)
	case "+":
		big.int_add(old, a, b)
	case:
		fmt.printf("got op:", desc[1])
		panic("bad op")
	}
}
