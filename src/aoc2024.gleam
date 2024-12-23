import day1
import day10
import day11
import day2
import day3
import day4
import day5
import day6
import day7
import day8
import day9
import gleam/int
import gleam/io
import gleam/string
import simplifile

pub fn main() {
  let input = "day11_large.txt"
  let solver = day11.solve1

  let assert Ok(content) = simplifile.read("inputs/" <> input)
  let lines = string.split(content, on: "\n")

  io.println(int.to_string(solver(lines)))
}
