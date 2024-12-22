import gleam/int
import gleam/list
import gleam/string
import util

pub fn solve1(lines: List(String)) -> Int {
  lines
  |> list.filter(fn(line) { line != "" })
  |> list.map(parse_line)
  |> list.filter(fn(eqn) { satisfiable(eqn.0, eqn.1) })
  |> list.map(fn(eqn) { eqn.0 })
  |> int.sum
}

pub fn solve2(lines: List(String)) -> Int {
  todo
}

fn parse_line(line) {
  let assert [test_value_str, operands_str] = string.split(line, on: ": ")
  let test_value = util.must_string_to_int(test_value_str)
  let operands =
    operands_str |> string.split(on: " ") |> list.map(util.must_string_to_int)

  #(test_value, operands)
}

fn satisfiable(test_value, operands) {
  list.range(0, int.bitwise_shift_left(1, list.length(operands) - 1) - 1)
  |> list.map(compute(operands, _))
  |> list.any(fn(x) { x == test_value })
}

fn compute(operands, operators_bitmap) {
  case operands {
    [] -> panic as "no operands"
    [x] -> x
    [x1, x2, ..xs] ->
      case int.bitwise_and(operators_bitmap, 1) == 0 {
        False ->
          compute([x1 + x2, ..xs], int.bitwise_shift_right(operators_bitmap, 1))
        True ->
          compute([x1 * x2, ..xs], int.bitwise_shift_right(operators_bitmap, 1))
      }
  }
}
