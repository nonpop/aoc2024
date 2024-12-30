import gleam/dict.{type Dict}
import gleam/list
import gleam/option
import gleam/result
import gleam/set.{type Set}
import gleam/string

pub fn solve1(lines: List(String)) -> Int {
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
}

pub fn solve2(lines: List(String)) -> Int {
  todo
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
  Graph(nodes: Set(String), adj: Dict(String, Set(String)))
}

fn new_graph() {
  Graph(nodes: set.new(), adj: dict.new())
}

fn add_edge(graph, a, b) {
  let Graph(nodes:, adj:) = graph

  let nodes =
    nodes
    |> set.insert(a)
    |> set.insert(b)

  let adj =
    adj
    |> dict.upsert(a, fn(xs) { set.insert(option.unwrap(xs, set.new()), b) })
    |> dict.upsert(b, fn(xs) { set.insert(option.unwrap(xs, set.new()), a) })

  Graph(nodes:, adj:)
}

fn has_edge(graph: Graph, a, b) {
  graph.adj |> dict.get(a) |> result.unwrap(set.new()) |> set.contains(b)
}

fn nodes(graph: Graph) {
  graph.nodes
}

fn adj(graph: Graph, node) {
  graph.adj |> dict.get(node) |> result.unwrap(set.new())
}
