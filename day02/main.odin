package main

import "core:os"
import "core:fmt"
import "core:strings"

main :: proc() {
	//data, ok := os.read_entire_file_from_filename("sample.txt")
	data, ok := os.read_entire_file_from_filename("input1.txt")
	if !ok {
		fmt.println("err reading input")
	}

	score := 0
	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		choices := strings.fields(line)
		defer {
			delete(choices)
		}

		switch choices[1] {
		case "X":
			score += 1
			switch choices[0] {
			case "A":
				score += 3
			case "C":
                score += 6
			}
		case "Y":
			score += 2
			switch choices[0] {
			case "A":
				score += 6
			case "B":
                score += 3
			}
		case "Z":
			score += 3
			switch choices[0] {
			case "B":
				score += 6
			case "C":
                score += 3
			}
		}
	}

    fmt.println("Score:", score)
}
