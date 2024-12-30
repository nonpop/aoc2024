import gleam/int
import gleam/list
import util

pub fn solve1(lines: List(String)) -> Int {
  parse(lines)
  |> list.map(generate(_, 2000))
  |> int.sum
}

pub fn solve2(lines: List(String)) -> Int {
  todo
}

fn generate(seed, n) {
  case n <= 0 {
    True -> seed
    False -> generate(step(seed), n - 1)
  }
}

fn step(seed) {
  let s1 = int.bitwise_exclusive_or(seed * 64, seed) % 16_777_216
  let s2 = int.bitwise_exclusive_or(s1 / 32, s1) % 16_777_216
  let s3 = int.bitwise_exclusive_or(s2 * 2048, s2) % 16_777_216
  s3
}

fn parse(lines) {
  lines
  |> list.filter(fn(line) { line != "" })
  |> list.map(util.must_string_to_int)
}
