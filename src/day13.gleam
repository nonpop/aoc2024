import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import util

pub fn solve1(lines: List(String)) -> Int {
  parse(lines)
  |> list.map(brute_force_smallest_cost(_, 3, 100, 1, 100))
  |> int.sum
}

pub fn solve2(lines: List(String)) -> Int {
  todo
}

fn brute_force_smallest_cost(machine, a_cost, a_max, b_cost, b_max) {
  let a_presses = list.range(0, a_max)
  let b_presses = list.range(0, b_max)
  let presses =
    a_presses
    |> list.flat_map(fn(a) {
      b_presses
      |> list.map(fn(b) { #(a, b) })
    })

  presses
  |> list.filter_map(cost(_, machine, a_cost, b_cost))
  |> min_or_zero
}

fn min_or_zero(xs) {
  case xs {
    [] -> 0
    [x] -> x
    [x, y, ..xs] -> min_or_zero([int.min(x, y), ..xs])
  }
}

fn cost(presses, machine: Machine, a_cost, b_cost) {
  let #(a_presses, b_presses) = presses

  let final_x = a_presses * machine.but_a_x + b_presses * machine.but_b_x
  let final_y = a_presses * machine.but_a_y + b_presses * machine.but_b_y

  case final_x == machine.prize_x && final_y == machine.prize_y {
    True -> Ok(a_presses * a_cost + b_presses * b_cost)
    False -> Error(Nil)
  }
}

fn parse(lines) {
  lines
  |> list.filter(fn(line) { line != "" })
  |> list.sized_chunk(3)
  |> list.map(parse_machine)
}

type Machine {
  Machine(
    but_a_x: Int,
    but_a_y: Int,
    but_b_x: Int,
    but_b_y: Int,
    prize_x: Int,
    prize_y: Int,
  )
}

fn parse_machine(lines) {
  let assert Ok(but_a_re) =
    regexp.from_string("^Button A: X\\+(\\d+), Y\\+(\\d+)$")
  let assert Ok(but_b_re) =
    regexp.from_string("^Button B: X\\+(\\d+), Y\\+(\\d+)$")
  let assert Ok(price_re) = regexp.from_string("^Prize: X=(\\d+), Y=(\\d+)$")

  let assert [but_a_line, but_b_line, prize_line] = lines
  let assert [
    regexp.Match(
      submatches: [Some(but_a_x_str), Some(but_a_y_str)],
      ..,
    ),
  ] = regexp.scan(but_a_re, but_a_line)

  let assert [
    regexp.Match(
      submatches: [Some(but_b_x_str), Some(but_b_y_str)],
      ..,
    ),
  ] = regexp.scan(but_b_re, but_b_line)

  let assert [
    regexp.Match(
      submatches: [Some(prize_x_str), Some(prize_y_str)],
      ..,
    ),
  ] = regexp.scan(price_re, prize_line)

  let but_a_x = util.must_string_to_int(but_a_x_str)
  let but_a_y = util.must_string_to_int(but_a_y_str)
  let but_b_x = util.must_string_to_int(but_b_x_str)
  let but_b_y = util.must_string_to_int(but_b_y_str)
  let prize_x = util.must_string_to_int(prize_x_str)
  let prize_y = util.must_string_to_int(prize_y_str)

  Machine(but_a_x:, but_a_y:, but_b_x:, but_b_y:, prize_x:, prize_y:)
}
