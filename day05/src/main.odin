package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"

main :: proc() {
	data, ok := os.read_entire_file_from_filename("sample.txt")
	//data, ok := os.read_entire_file_from_filename("input.txt")
	if !ok {
		fmt.println("error reading input file")
		return
	}

	groups := strings.split(string(data), "\n\n")
	defer delete(groups)

	num_stacks := strconv.atoi(groups[0])
	stacks := [dynamic][dynamic]string{}

	lines := strings.split_lines(groups[1])
	for l in lines {
		newl := strings.fields(l)
		slice.reverse(newl)
		append(&stacks, slice.to_dynamic(newl))
	}
	delete(lines)
	defer delete(stacks)

	for s, i in stacks {
		fmt.println("stack", i, s)
	}

	lines = strings.split_lines(groups[2])
	for l in lines {
		if len(l) == 0 {continue}
		tokens := strings.fields(l)
		defer delete(tokens)

		num := strconv.atoi(tokens[1])
		src := strconv.atoi(tokens[3])
		dst := strconv.atoi(tokens[5])

		containers := [dynamic]string{}
		defer delete(containers)

		for i := 0; i < num; i += 1 {
			append(&containers, pop(&stacks[src - 1]))
		}
		for i := 0; i < num; i += 1 {
			// pt1:
            //append(&stacks[dst - 1], pop_front(&containers))
            
            // pt2:
            append(&stacks[dst - 1], pop(&containers))
		}
		// for s, i in stacks {
		// 	fmt.println("stack", i, s)
		// }
		// fmt.println()
	}

	for s in stacks {
		fmt.print(slice.last(s[:]))
	}
	fmt.println()
}
