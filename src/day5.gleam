import gleam/int
import gleam/list
import gleam/string
import util

pub fn solve1(lines: List(String)) -> Int {
  let #(rules, orderings) = parse(lines)

  orderings
  |> list.filter(in_right_order(rules, _))
  |> list.map(take_middle)
  |> int.sum
}

pub fn solve2(lines: List(String)) -> Int {
  todo
}

fn parse(lines) {
  let assert [rule_lines, ordering_lines] =
    lines
    |> string.join(with: "\n")
    |> string.split(on: "\n\n")
    |> list.map(string.split(_, on: "\n"))

  #(
    rule_lines |> list.filter(fn(line) { line != "" }) |> list.map(parse_rule),
    ordering_lines
      |> list.filter(fn(line) { line != "" })
      |> list.map(parse_ordering),
  )
}

fn parse_rule(line) {
  let assert [before, after] = string.split(line, on: "|")
  #(util.must_string_to_int(before), util.must_string_to_int(after))
}

fn parse_ordering(line) {
  line
  |> string.split(on: ",")
  |> list.map(util.must_string_to_int)
}

fn in_right_order(rules, ordering) {
  case ordering {
    [] -> True
    [x, ..xs] -> in_right_order_wrt(rules, x, xs) && in_right_order(rules, xs)
  }
}

fn in_right_order_wrt(rules, x, xs) {
  case xs {
    [] -> True
    [y, ..ys] ->
      pair_in_right_order(rules, x, y) && in_right_order_wrt(rules, x, ys)
  }
}

fn pair_in_right_order(rules, x, y) {
  rules
  |> list.all(fn(rule) { #(y, x) != rule })
}

fn take_middle(ordering) {
  let len = list.length(ordering)
  let middle_idx = len / 2

  ordering
  |> list.drop(middle_idx)
  |> list.first
  |> util.assert_ok
}
