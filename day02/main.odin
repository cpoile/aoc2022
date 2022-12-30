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
			score += 0 // lost
			switch choices[0] {
			case "A": // they chose rock, I chose scissor
				score += 3
			case "B": // them: paper, me: rock
                score += 1
			case "C": // them: scissor, me: paper
                score += 2
			}
		case "Y":
			score += 3 // tie
			switch choices[0] {
			case "A": // they chose rock, I chose rock
				score += 1
			case "B": // them: paper, me: paper
                score += 2
			case "C": // them: scissor, me: scissor
                score += 3
			}
		case "Z":
			score += 6 // won
			switch choices[0] {
			case "A": // they chose rock, I chose paper
				score += 2
			case "B": // them: paper, me: scissor
                score += 3
			case "C": // them: scissor, me: rock
                score += 1
			}
		}
	}

    fmt.println("Score:", score)
}
