package main

import "core:os"
import "core:strings"
import "core:fmt"
import "core:slice"
import "core:strconv"

main :: proc() {
	//data, ok := os.read_entire_file_from_filename("sample.txt")
	data, ok := os.read_entire_file_from_filename("input.txt")
	if !ok {
		panic("cannot read file")
	}

	lines := strings.split_lines(string(data))

	grid := slice.mapper(lines, proc(l: string) -> []int {
		return slice.mapper(strings.split(l, ""), strconv.atoi)
	})

	max_count := 0

	for r := 0; r < len(grid); r += 1 {
		for c := 0; c < len(grid[0]); c += 1 {
			count :=
				count_to(.N, grid, r, c) *
				count_to(.E, grid, r, c) *
				count_to(.S, grid, r, c) *
				count_to(.W, grid, r, c)
            max_count = max(count, max_count)
		}
	}

	fmt.println("Most visible:", max_count)
}

Dir :: enum {
	N,
	E,
	S,
	W,
}

count_to :: proc(dir: Dir, grid: [][]int, start_r, start_c: int) -> int {
	change_r, change_c: int
	switch dir {
	case .N:
		change_r = -1
	case .E:
		change_c = 1
	case .S:
		change_r = 1
	case .W:
		change_c = -1
	}

	count := 0
	height := grid[start_r][start_c]
	r := start_r + change_r
	c := start_c + change_c

	for r >= 0 && r < len(grid) && c >= 0 && c < len(grid[0]) {
		count += 1
		if grid[r][c] >= height {
			break
		}
		r += change_r
		c += change_c
	}
	return count
}

clear_to :: proc(dir: Dir, grid: [][]int, start_r, start_c: int) -> bool {
	change_r, change_c: int
	switch dir {
	case .N:
		change_r = -1
	case .E:
		change_c = 1
	case .S:
		change_r = 1
	case .W:
		change_c = -1
	}

	height := grid[start_r][start_c]
	r := start_r + change_r
	c := start_c + change_c

	for r >= 0 && r < len(grid) && c >= 0 && c < len(grid[0]) {
		if grid[r][c] >= height {
			return false
		}
		r += change_r
		c += change_c
	}
	return true
}
