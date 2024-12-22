import day1
import day2
import day3
import day4
import day5
import day6
import gleam/int
import gleam/io
import gleam/string
import simplifile

pub fn main() {
  let input = "day6_large.txt"
  let solver = day6.solve1

  let assert Ok(content) = simplifile.read("inputs/" <> input)
  let lines = string.split(content, on: "\n")

  io.println(int.to_string(solver(lines)))
}
