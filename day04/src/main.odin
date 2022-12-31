package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:slice"
import "core:strconv"

main :: proc() {
	//data, ok := os.read_entire_file_from_filename("sample.txt")
	data, ok := os.read_entire_file_from_filename("input.txt")
	if !ok {
		fmt.println("error reading file")
		return
	}
	defer delete(data)

    count := 0
	it := string(data)
	for l in strings.split_lines_iterator(&it) {
		ranges := strings.split(l, ",")
        first := slice.mapper(strings.split(ranges[0], "-")[:], strconv.atoi)
        second := slice.mapper(strings.split(ranges[1], "-")[:], strconv.atoi)
        if overlap(first, second) {
            count += 1
        }
	}

    fmt.println(count)
}

overlap :: proc(first: []int, second: []int) -> bool {
	return(
		(first[1] >= second[0] && first[1] <= second[1]) ||
		(second[1] >= first[0] && second[1] <= first[1]) \
	)
}

in_range :: proc(first: []int, second: []int) -> bool {
	return(
		(first[0] >= second[0] && first[1] <= second[1]) ||
		(second[0] >= first[0] && second[1] <= first[1]) \
	)
}

pt1 :: proc() {
	//data, ok := os.read_entire_file_from_filename("sample.txt")
	data, ok := os.read_entire_file_from_filename("input.txt")
	if !ok {
		fmt.println("error reading file")
		return
	}
	defer delete(data)

    count := 0
	it := string(data)
	for l in strings.split_lines_iterator(&it) {
		ranges := strings.split(l, ",")
        first := slice.mapper(strings.split(ranges[0], "-")[:], strconv.atoi)
        second := slice.mapper(strings.split(ranges[1], "-")[:], strconv.atoi)
        if in_range(first, second) {
            count += 1
        }
	}

    fmt.println(count)
}
