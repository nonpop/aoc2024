import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import util

pub fn main() {
  util.run(solve1, solve2)
}

fn solve1(lines) {
  let #(rules, orderings) = parse(lines)

  orderings
  |> list.filter(in_right_order(rules, _))
  |> list.map(take_middle)
  |> int.sum
  |> util.print_int
}

fn solve2(lines) {
  let #(rules, orderings) = parse(lines)

  orderings
  |> list.filter(fn(ordering) { !in_right_order(rules, ordering) })
  |> list.map(order(rules, _))
  |> list.map(take_middle)
  |> int.sum
  |> util.print_int
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

fn order(rules, pages) {
  case pages {
    [] -> []
    _ -> {
      let assert Some(#(init, first, tail)) = find_first(rules, [], pages)
      [first, ..order(rules, list.append(init, tail))]
    }
  }
}

fn find_first(rules, init, tail) {
  case tail {
    [] -> None
    [x, ..xs] ->
      case can_be_before_all(rules, x, list.append(init, xs)) {
        True -> Some(#(init, x, xs))
        False -> find_first(rules, [x, ..init], xs)
      }
  }
}

fn can_be_before_all(rules, x, xs) {
  list.all(xs, fn(y) { pair_in_right_order(rules, x, y) })
}
