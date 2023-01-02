package main

import "core:os"
import "core:strings"
import "core:fmt"
import "core:strconv"

Node :: struct {
	parent:   ^Node,
	size:     int,
	children: map[string]Node,
}

new_node :: proc(parent: ^Node, size: int = 0) -> Node {
	return Node{parent, size, make(map[string]Node)}
}

main :: proc() {
	//data, ok := os.read_entire_file_from_filename("sample.txt")
	data, ok := os.read_entire_file_from_filename("input.txt")
	if !ok {
		fmt.println("error reading file")
		return
	}
	defer delete(data)

	root := new_node(nil)
	cur := &root

	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		if strings.has_prefix(line, "$ ls") {
			// continue to the listing.
		} else if strings.has_prefix(line, "$ cd") {
			if strings.has_prefix(line, "$ cd ..") {
				// move up
				cur = cur.parent
			} else {
				// move in
				fs := strings.fields(line)
				defer delete(fs)

				ok := fs[2] in cur.children
				if !ok {
					fmt.println("couldn't find dir", fs[2])
				}
				cur = &cur.children[fs[2]]
			}
		} else if strings.has_prefix(line, "dir") {
			// create a dir
			fs := strings.fields(line)
			defer delete(fs)

			cur.children[fs[1]] = new_node(cur)
		} else {
			// must be a file
			fs := strings.fields(line)
			defer delete(fs)

			sz := strconv.atoi(fs[0])
			cur.children[fs[1]] = new_node(cur, sz)
		}
	}

	root.size = children_size(&root)

	print_children(root)
	fmt.println("root sz:", root.size)

	// pt1:
	// total := reduce_add_tree(root, 0, proc(accum: int, cur: Node) -> int {
	//     if cur.size <= 100_000 && len(cur.children) != 0 { // only count directories
	//         return accum + cur.size
	//     }
	//     return accum
	// })
	//
	// fmt.println("total:", total)

	// pt2:
	fmt.println("unused space:", 70_000_000 - root.size)
	free_atleast := 30_000_000 - (70_000_000 - root.size)
	fmt.println("need to free up at least:", free_atleast)
	
	smallest_dir := reduce_tree(root, free_atleast, 999999999999, proc(test, accum: int, cur: Node) -> int {
		if len(cur.children) != 0 && cur.size >= test {
			return min(accum, cur.size)
		}
		return accum
	})

	fmt.println("smallest dir size:", smallest_dir)
}

reduce_tree :: proc(node: Node, test, init: int, f: proc(test, accum: int, cur: Node) -> int) -> int {
	r := init
	for k, v in node.children {
		r = reduce_tree(v, test, r, f)
	}
	r = f(test, r, node)
	return r
}


reduce_add_tree :: proc(node: Node, init: int, f: proc(accum: int, cur: Node) -> int) -> int {
	r := init
	for k, v in node.children {
		r += reduce_add_tree(v, init, f)
	}
	r = f(r, node)
	return r
}

children_size :: proc(node: ^Node) -> int {
	sum := 0
	for k, v in &node.children {
		sum += children_size(&v)
	}
	node.size += sum
	return node.size
}

print_children :: proc(node: Node) {
	for k, v in node.children {
		fmt.println("k:", k, "sz:", v.size)
		print_children(v)
	}
}
