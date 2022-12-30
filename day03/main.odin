package main

import "core:os"
import "core:fmt"
import "core:strings"

main :: proc() {
	//data, ok := os.read_entire_file_from_filename("sample.txt")
	data, ok := os.read_entire_file_from_filename("input.txt")
	defer delete(data)
	if !ok {
		fmt.println("error reading file")
	}

	sum := 0
	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		trimmed := strings.trim_space(line)
		first := trimmed[:len(trimmed) / 2]
		second := trimmed[len(trimmed) / 2:]

		counts: [53]int
		for c in first {
			counts[val(c)] += 1
		}
		for c in second {
			if counts[val(c)] > 0 {
				sum += val(c)
				break
			}
		}
	}

	fmt.println("total:", sum)
}

val :: proc(char: rune) -> int {
	if int(char) > 96 {
		return int(char) - 'a' + 1
	}
	return int(char) - 'A' + 27
}
