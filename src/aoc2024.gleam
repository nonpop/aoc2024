import day1
import day10
import day11
import day12
import day13
import day14
import day15
import day16
import day17
import day18
import day19
import day2
import day20
import day21
import day22
import day23
import day24
import day25
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
  let input = "day25_large.txt"
  let solver = day25.solve2

  let assert Ok(content) = simplifile.read("inputs/" <> input)
  let lines = string.split(content, on: "\n")
  let result = solver(lines)

  case result >= 0 {
    True -> io.println(int.to_string(result))
    False -> Nil
  }
}
