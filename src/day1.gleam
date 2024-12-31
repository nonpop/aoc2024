import gleam/int
import gleam/list
import gleam/string
import util

pub fn main() {
  util.run(solve1, solve2)
}

fn solve1(lines) {
  let #(list1, list2) = parse(lines)

  list.zip(list.sort(list1, by: int.compare), list.sort(list2, by: int.compare))
  |> list.map(fn(p) { int.absolute_value(p.0 - p.1) })
  |> int.sum
  |> util.print_int
}

fn solve2(lines) {
  let #(list1, list2) = parse(lines)

  list1
  |> list.map(fn(x) { x * count_occurrences(list2, x) })
  |> int.sum
  |> util.print_int
}

fn count_occurrences(xs, x) {
  xs
  |> list.filter(fn(y) { y == x })
  |> list.length
}

fn parse(lines) {
  lines
  |> list.filter(fn(s) { s != "" })
  |> list.map(parse_line)
  |> list.unzip
}

fn parse_line(line) {
  let assert [s1, s2] = string.split(line, on: "   ")
  let assert Ok(i1) = int.parse(s1)
  let assert Ok(i2) = int.parse(s2)
  #(i1, i2)
}
