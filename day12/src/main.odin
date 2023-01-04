package main

import "core:os"
import "core:strings"
import "core:fmt"
import "core:mem"

// main :: proc() {
// 	track: mem.Tracking_Allocator
// 	mem.tracking_allocator_init(&track, context.allocator)
// 	context.allocator = mem.tracking_allocator(&track)

// 	_main()

// 	for _, leak in track.allocation_map {
// 		fmt.printf("%v leaked %v bytes\n", leak.location, leak.size)
// 	}
// 	for bad_free in track.bad_free_array {
// 		fmt.printf("%v allocation %p was freed badly\n", bad_free.location, bad_free.memory)
// 	}
// }

Grid :: struct {
	w, h, size: int,
	grid:       []int,
}
make_grid :: proc(w, h: int, allocator := context.allocator) -> Grid {
	return Grid{w, h, w * h, make([]int, w * h, allocator)}
}
destroy_grid :: proc(grid: ^Grid) {
	delete(grid.grid)
}

main :: proc() {
	//data, ok := os.read_entire_file_from_filename("simple_sample.txt")
	//data, ok := os.read_entire_file_from_filename("sample.txt")
	data, ok := os.read_entire_file_from_filename("input.txt")
	if !ok {panic("couldn't read file")}
	defer delete(data)

	lines := strings.split_lines(string(data))
	defer delete(lines)

	grid := make_grid(len(lines[0]), len(lines))
	defer destroy_grid(&grid)

	// pt1:
	//start: int
	end: int
	as := [dynamic]int{}
	defer delete(as)

	for i in 0 ..< grid.size {
		r := i / grid.w
		c := i % grid.w

		if lines[r][c] == 'S' {
			// part1
			//start = i
			append(&as, i)
			// for visual tracking:
			grid.grid[i] = 100
		} else if lines[r][c] == 'E' {
			end = i
			grid.grid[i] = 26
		} else {
			if lines[r][c] == 'a' {append(&as, i)}
			grid.grid[i] = int(lines[r][c]) - 'a'
		}
	}

	// for i in 0 ..< grid.size {
	// 	if i % grid.w == 0 {fmt.println()}
	// 	fmt.printf("%d\t", grid.grid[i])
	// }
	// fmt.println()

	graph := make_graph(grid.size)
	defer destroy_graph(&graph)

	for v in 0 ..< grid.size {
		edges := get_adj(grid, v)
		add_edges(&graph, v, edges)
		delete(edges)
	}

	fmt.println("num a's:", len(as))

	// pt1:
	//djikstra_do(&graph, start)

	min_distance := max(int)
	for v, i in as {
		djikstra_do(&graph, v, end)
		min_distance = min(min_distance, graph.dist_to[end])
		fmt.printf(" %d", i)
	}
	fmt.println()

	fmt.println("minimum num steps:", min_distance)
}

get_adj :: proc(g: Grid, v: int, allocator := context.allocator) -> []Edge {
	edges := make([dynamic]Edge, 0, allocator)
	v_row := v / g.w
	// north: v - width  (unless past top edge)
	idx := v - g.w
	if idx >= 0 && g.grid[idx] - 1 <= g.grid[v] {
		append(&edges, Edge{v, idx, 1})
	}

	// south: v + width  (unless past bottom edge)
	idx = v + g.w
	if idx < g.size && g.grid[idx] - 1 <= g.grid[v] {
		append(&edges, Edge{v, idx, 1})
	}

	// west: v - 1  (unless past left edge, then no west)
	idx = v - 1
	idx_row := idx / g.w
	if idx >= 0 && v_row == idx_row && g.grid[idx] - 1 <= g.grid[v] {
		append(&edges, Edge{v, idx, 1})
	}

	// east: v + 1  (unless past right edge, then no east)
	idx = v + 1
	idx_row = idx / g.w
	if idx < g.size && v_row == idx_row && g.grid[idx] - 1 <= g.grid[v] {
		append(&edges, Edge{v, idx, 1})
	}

	return edges[:]
}
