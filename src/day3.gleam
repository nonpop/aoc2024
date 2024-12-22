import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleam/string
import util

pub fn solve1(lines: List(String)) -> Int {
  let assert Ok(re) = regexp.from_string("mul\\((\\d{1,3}),(\\d{1,3})\\)")
  let memory = string.concat(lines)

  regexp.scan(re, memory)
  |> list.map(operands)
  |> list.map(fn(p) { p.0 * p.1 })
  |> int.sum
}

fn operands(match: regexp.Match) {
  let assert [Some(s1), Some(s2)] = match.submatches
  #(util.must_string_to_int(s1), util.must_string_to_int(s2))
}

pub fn solve2(lines: List(String)) -> Int {
  todo
}
