import gleam/int
import gleam/list
import gleam/string

pub fn solve1(lines: List(String)) -> Int {
  let #(list1, list2) =
    lines
    |> list.map(parse_line)
    |> list.unzip

  list.zip(list.sort(list1, by: int.compare), list.sort(list2, by: int.compare))
  |> list.map(fn(p) { int.absolute_value(p.0 - p.1) })
  |> int.sum
}

fn parse_line(line: String) -> #(Int, Int) {
  let assert [s1, s2] = string.split(line, on: "   ")
  let assert Ok(i1) = int.parse(s1)
  let assert Ok(i2) = int.parse(s2)
  #(i1, i2)
}
