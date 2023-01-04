package main

import "core:fmt"
import pq "core:container/priority_queue"
import "core:slice"

Edge :: struct {
	v:         int,
	w, weight: int, // tail, head, weight
}

Graph :: struct {
	V, E:    int, // total vertices, number of edges
	adj:     [][dynamic]Edge, // for each v (tail), array of edges from it (tail->head)
	edge_to: []Edge,
	dist_to: []int,
}

IdxWeight :: struct {
	idx, weight: int,
}

make_graph :: proc(V: int, allocator := context.allocator) -> Graph {
	g := Graph {
		V       = V,
		E       = 0,
		adj     = make([][dynamic]Edge, V, allocator),
		edge_to = make([]Edge, V, allocator),
		dist_to = make([]int, V, allocator),
	}
	return g
}

djikstra_do :: proc(g: ^Graph, start, end: int) {
    less :: proc(a, b: IdxWeight) -> bool {
		return a.weight < b.weight
	}

    slice.fill(g.dist_to, max(int))
	g.dist_to[start] = 0

    minpq := pq.Priority_Queue(IdxWeight){}
    defer pq.destroy(&minpq)
    pq.init(&minpq, less, pq.default_swap_proc(IdxWeight))

    pq.push(&minpq, IdxWeight{start, 0})

    for pq.len(minpq) > 0 {
        next := pq.pop(&minpq)
        relax(g, &minpq, next)
        if next.idx == end {
            return
        }
    }
}

pq_contains :: proc(minpq: ^pq.Priority_Queue(IdxWeight), idx: int) -> (int, bool) {
    for it, i in minpq.queue {
        if it.idx == idx {
            return i, true
        }
    }
    return 0, false
}

pq_change :: proc(minpq: ^pq.Priority_Queue(IdxWeight), idx, weight: int) {
    queue_idx, found := pq_contains(minpq, idx)
    if !found {
        fmt.println("didn't find idx", idx, "but tried to change it")
        panic("didn't find idx")
    }

    item, ok := pq.remove(minpq, queue_idx)
    if !ok {
        fmt.println("didn't remove idx", queue_idx)
        panic("didn't remove")
    }

    item.weight = weight
    pq.push(minpq, item)
}

relax :: proc(graph: ^Graph, minpq: ^pq.Priority_Queue(IdxWeight), next: IdxWeight) {
    v := next.idx
	for e in graph.adj[v] {
		w := e.w
		if graph.dist_to[w] > graph.dist_to[v] + e.weight {
			graph.dist_to[w] = graph.dist_to[v] + e.weight
			graph.edge_to[w] = e
            if idx, ok := pq_contains(minpq, w); ok {
                pq_change(minpq, idx, graph.dist_to[w])
            } else {
                pq.push(minpq, IdxWeight{w, graph.dist_to[w]})
            }
		}
	}
}


destroy_graph :: proc(graph: ^Graph) {
	for v in 0 ..< graph.V {
		delete(graph.adj[v])
	}
	delete(graph.adj)
	delete(graph.edge_to)
	delete(graph.dist_to)
}

add_edges :: proc(graph: ^Graph, v: int, edges: []Edge) {
	append(&graph.adj[v], ..edges)
	graph.E += 1
}

adj :: proc(graph: ^Graph, v: int) -> []Edge {
	return graph.adj[v][:]
}

edges :: proc(graph: ^Graph, allocator := context.allocator) -> []Edge {
	edges := make([]Edge, graph.E, allocator)
	ne := 0
	for v in 0 ..< graph.V {
		for e in graph.adj[v] {
			edges[ne] = e
			ne += 1
		}
	}

	return edges
}

print :: proc(graph: ^Graph) {
	for v in 0 ..< graph.V {
		for e in graph.adj[v] {
			fmt.printf(" %d to %d ", e.v, e.w)
		}
		fmt.println()
	}
}
