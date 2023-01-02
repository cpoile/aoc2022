package main

import "core:os"
import "core:strings"
import "core:fmt"
import "core:strconv"
import "core:slice"

// assume a size, change manually if needed
DIM :: 350
visited: [DIM][DIM]bool

change_x := map[string]int {
	"U" = 0,
	"R" = 1,
	"D" = 0,
	"L" = -1,
}
change_y := map[string]int {
	"U" = 1,
	"R" = 0,
	"D" = -1,
	"L" = 0,
}

Point :: struct {
	x, y: int,
}

main :: proc() {
	//data, ok := os.read_entire_file_from_filename("sample.txt")
	data, ok := os.read_entire_file_from_filename("input.txt")
	if !ok {panic("error reading file")}
	defer delete(data)

	knots := [10]Point{}
	for k in &knots {
		k.x, k.y = DIM / 2, DIM / 2
	}

	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		l := strings.fields(line)
		defer delete(l)

		dir := l[0]
		count := strconv.atoi(l[1])

		for count > 0 {
			knots[0].x += change_x[dir]
			knots[0].y += change_y[dir]

			// check if we need to make grid bigger
			if knots[0].x < 0 || knots[0].y < 0 || knots[0].x >= DIM || knots[0].y >= DIM {
				fmt.println(
					"reached knots[0].x, knots[0].y:",
					knots[0].x,
					knots[0].y,
					"need to expand",
				)
				panic("OOB")
			}

			// go through each knot, move it closer to the one before it.
			for i := 1; i < 10; i += 1 {
				hx, hy := knots[i - 1].x, knots[i - 1].y
				tx, ty := knots[i].x, knots[i].y
                
				// if knot is not touching, we need to move it
				if !(abs(hx - tx) <= 1 && abs(hy - ty) <= 1) {
					dx, dy := dir_to(hx, hy, tx, ty)
					knots[i].x += dx
					knots[i].y += dy
				}
			}

			count -= 1
			visited[knots[9].y][knots[9].x] = true
		}
	}

	// for y := DIM - 1; y >= 0; y -= 1 {
	// 	for v in visited[y] {
	// 		if v {fmt.print("#")} else {fmt.print(".")}
	// 	}
	// 	fmt.print("\n")
	// }

	count := 0
	for y in visited {
		for v in y {
			if v {count += 1}
		}
	}
	fmt.println("visited:", count)
}

dir_to :: proc(dst_x, dst_y, src_x, src_y: int) -> (int, int) {
	return clamp(dst_x - src_x, -1, 1), clamp(dst_y - src_y, -1, 1)
}
