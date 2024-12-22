import gleam/int
import gleam/list
import gleam/string
import util

pub fn solve1(lines: List(String)) -> Int {
  solve(lines, [Add, Mul])
}

pub fn solve2(lines: List(String)) -> Int {
  solve(lines, [Add, Mul, Concat])
}

fn solve(lines, ops) {
  lines
  |> list.filter(fn(line) { line != "" })
  |> list.map(parse_line)
  |> list.filter(fn(eqn) { satisfiable(eqn.0, eqn.1, ops) })
  |> list.map(fn(eqn) { eqn.0 })
  |> int.sum
}

fn parse_line(line) {
  let assert [test_value_str, operands_str] = string.split(line, on: ": ")
  let test_value = util.must_string_to_int(test_value_str)
  let operands =
    operands_str |> string.split(on: " ") |> list.map(util.must_string_to_int)

  #(test_value, operands)
}

type Op {
  Add
  Mul
  Concat
}

fn combine(op, x, y) {
  case op {
    Add -> x + y
    Mul -> x * y
    Concat -> util.must_string_to_int(int.to_string(x) <> int.to_string(y))
  }
}

fn ops_lists(of, len) {
  case len <= 1 {
    True -> list.map(of, fn(op) { [op] })
    False -> {
      let tails = ops_lists(of, len - 1)

      of
      |> list.map(fn(op) { tails |> list.map(fn(tail) { [op, ..tail] }) })
      |> list.flatten
    }
  }
}

fn satisfiable(test_value, operands, ops) {
  ops_lists(ops, list.length(operands) - 1)
  |> list.map(compute(operands, _))
  |> list.any(fn(x) { x == test_value })
}

fn compute(operands, operators) {
  case operands {
    [] -> panic as "no operands"
    [x] -> x
    [x1, x2, ..xs] ->
      case operators {
        [] -> panic as "no operators"
        [op, ..ops] -> compute([combine(op, x1, x2), ..xs], ops)
      }
  }
}
