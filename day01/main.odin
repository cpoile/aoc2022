package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"

main :: proc() {
	//data, err := os.read_entire_file_from_filename("sample_in.txt")
	data, err := os.read_entire_file_from_filename("input1.txt")
	if !err {
		fmt.println("error opening file:", err)
		return
	}
	defer delete(data)

	elves := make([dynamic]int)
	defer delete(elves)

	it := string(data)
	cur := 0
	max := 0
	for line in strings.split_lines_iterator(&it) {
		if (len(line) > 0) {
			val, ok := strconv.parse_int(line)
			if !ok {
				fmt.println("error parsing", line)
				return
			}
			cur += val
		} else {
			append(&elves, cur)
			if cur > max {
				max = cur
			}
			cur = 0
		}
	}

	if cur > 0 {
		append(&elves, cur)
	}

	// part 1:
	//fmt.println(max)

	slice.reverse_sort(elves[:])

	top3 := 0
	for i := 0; i < 3; i += 1 {
		fmt.println("elf:", elves[i])
		top3 += elves[i]
	}
	fmt.println(top3)
}
