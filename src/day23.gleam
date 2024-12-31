import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/result
import gleam/set.{type Set}
import gleam/string
import util

pub fn main() {
  util.run(solve1, solve2)
}

fn solve1(lines) {
  let graph = parse(lines)

  nodes(graph)
  |> set.to_list
  |> list.filter(fn(node) { node |> string.starts_with("t") })
  |> list.flat_map(fn(t_node) {
    adj(graph, t_node)
    |> set.to_list
    |> list.combination_pairs
    |> list.map(fn(p) { #(t_node, p.0, p.1) })
  })
  |> list.filter(fn(cand) { has_edge(graph, cand.1, cand.2) })
  |> list.map(fn(s) { set.from_list([s.0, s.1, s.2]) })
  |> set.from_list
  |> set.size
  |> util.print_int
}

fn solve2(lines) {
  parse(lines)
  |> maximal_cliques
  |> list.sort(fn(a, b) { int.compare(set.size(a), set.size(b)) })
  |> list.last
  |> result.lazy_unwrap(fn() { panic })
  |> set.to_list
  |> list.sort(string.compare)
  |> string.join(with: ",")
  |> io.println
}

fn parse(lines) {
  lines
  |> list.filter(fn(line) { line != "" })
  |> list.map(fn(line) {
    let assert [x, y] = string.split(line, on: "-")
    #(x, y)
  })
  |> list.fold(new_graph(), fn(graph, edge) { add_edge(graph, edge.0, edge.1) })
}

type Graph {
  Graph(adj: Dict(String, Set(String)))
}

fn new_graph() {
  Graph(adj: dict.new())
}

fn add_edge(graph, a, b) {
  let Graph(adj:) = graph

  let adj =
    adj
    |> dict.upsert(a, fn(xs) { set.insert(option.unwrap(xs, set.new()), b) })
    |> dict.upsert(b, fn(xs) { set.insert(option.unwrap(xs, set.new()), a) })

  Graph(adj:)
}

fn has_edge(graph: Graph, a, b) {
  graph.adj |> dict.get(a) |> result.unwrap(set.new()) |> set.contains(b)
}

fn nodes(graph: Graph) {
  set.from_list(dict.keys(graph.adj))
}

fn adj(graph: Graph, node) {
  graph.adj |> dict.get(node) |> result.unwrap(set.new())
}

fn maximal_cliques(graph) {
  bron_kerbosch(graph, set.new(), nodes(graph), set.new()).3
}

fn bron_kerbosch(graph, r, p, x) {
  let found = case set.is_empty(p) && set.is_empty(x) {
    True -> [r]
    False -> []
  }

  p
  |> set.to_list
  |> list.fold(#(r, p, x, found), fn(acc, v) {
    let #(r, p, x, found) = acc

    let #(_, _, _, rec_found) =
      bron_kerbosch(
        graph,
        set.insert(r, v),
        set.intersection(p, adj(graph, v)),
        set.intersection(x, adj(graph, v)),
      )

    let found = list.append(found, rec_found)

    #(r, set.delete(p, v), set.insert(x, v), found)
  })
}
