import gleam/int
import gleam/list
import gleam/order
import gleam/string
import util

pub fn solve1(lines: List(String)) -> Int {
  lines
  |> list.filter(fn(s) { s != "" })
  |> list.map(parse_line)
  |> list.filter(is_safe)
  |> list.length
}

fn is_safe(report) {
  let assert [x1, x2, ..] = report
  let order = int.compare(x1, x2)
  report_good(report, order)
}

fn good_dir(x1, x2, order) {
  case order {
    order.Lt -> x1 < x2
    order.Eq -> False
    order.Gt -> x1 > x2
  }
}

fn good_dist(x1, x2) {
  let dist = int.absolute_value(x1 - x2)
  1 <= dist && dist <= 3
}

fn report_good(xs, order) {
  case xs {
    [] | [_] -> True
    [x1, x2, ..xs] ->
      good_dir(x1, x2, order)
      && good_dist(x1, x2)
      && report_good([x2, ..xs], order)
  }
}

pub fn solve2(lines: List(String)) -> Int {
  lines
  |> list.filter(fn(s) { s != "" })
  |> list.map(parse_line)
  |> list.filter(is_safe2)
  |> list.length
}

fn is_safe2(report) {
  is_safe(report) || list.any(candidates([], report), is_safe)
}

fn candidates(init, tail) {
  case tail {
    [] -> []
    [x, ..xs] -> [
      list.append(init, xs),
      ..candidates(list.append(init, [x]), xs)
    ]
  }
}

fn parse_line(line) {
  line
  |> string.split(on: " ")
  |> list.map(util.must_string_to_int)
}
