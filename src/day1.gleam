import gleam/int
import gleam/list
import gleam/string

pub fn solve1(lines: List(String)) -> Int {
  let #(list1, list2) = parse_lines(lines)

  list.zip(list.sort(list1, by: int.compare), list.sort(list2, by: int.compare))
  |> list.map(fn(p) { int.absolute_value(p.0 - p.1) })
  |> int.sum
}

pub fn solve2(lines: List(String)) -> Int {
  let #(list1, list2) = parse_lines(lines)

  list1
  |> list.map(fn(x) { x * count_occurrences(list2, x) })
  |> int.sum
}

fn count_occurrences(xs: List(Int), x: Int) -> Int {
  xs
  |> list.filter(fn(y) { y == x })
  |> list.length
}

fn parse_lines(lines: List(String)) -> #(List(Int), List(Int)) {
  lines
  |> list.filter(fn(s) { s != "" })
  |> list.map(parse_line)
  |> list.unzip
}

fn parse_line(line: String) -> #(Int, Int) {
  let assert [s1, s2] = string.split(line, on: "   ")
  let assert Ok(i1) = int.parse(s1)
  let assert Ok(i2) = int.parse(s2)
  #(i1, i2)
}
