import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/pair
import gleam/regexp
import gleam/string
import util

pub fn main() {
  util.run(solve1, solve2)
}

fn solve1(lines) {
  let assert Ok(re) = regexp.from_string("mul\\((\\d{1,3}),(\\d{1,3})\\)")
  let memory = string.concat(lines |> list.filter(fn(s) { s != "" }))

  regexp.scan(re, memory)
  |> list.map(operands)
  |> list.map(fn(p) { p.0 * p.1 })
  |> int.sum
  |> util.print_int
}

fn solve2(lines) {
  let assert Ok(re) =
    regexp.from_string("do\\(\\)|don't\\(\\)|mul\\((\\d{1,3}),(\\d{1,3})\\)")
  let memory = string.concat(lines |> list.filter(fn(s) { s != "" }))

  regexp.scan(re, memory)
  |> list.fold(from: #(True, 0), with: step)
  |> pair.second
  |> util.print_int
}

fn operands(match: regexp.Match) {
  let assert [Some(s1), Some(s2)] = match.submatches
  #(util.must_string_to_int(s1), util.must_string_to_int(s2))
}

fn step(state, match: regexp.Match) {
  let #(enabled, acc) = state
  case match.content {
    "do()" -> #(True, acc)
    "don't()" -> #(False, acc)
    _ ->
      case enabled {
        False -> state
        True -> {
          let #(d1, d2) = operands(match)
          #(True, acc + d1 * d2)
        }
      }
  }
}
