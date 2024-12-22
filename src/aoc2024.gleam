import day1
import day2
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() {
  let input = "day2_large.txt"
  let solver = day2.solve1

  let assert Ok(content) = simplifile.read("inputs/" <> input)
  let lines = string.split(content, on: "\n") |> list.filter(fn(s) { s != "" })

  io.println(int.to_string(solver(lines)))
}
