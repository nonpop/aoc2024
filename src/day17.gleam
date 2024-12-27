import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import util

pub fn solve1(lines: List(String)) -> Int {
  let machine = parse(lines)

  run(machine, [])
  |> list.map(int.to_string)
  |> list.reverse
  |> string.join(with: ",")
  |> io.println

  -1
}

pub fn solve2(lines: List(String)) -> Int {
  let machine = parse(lines)
  let xs = [5, 3, 2, 2, 3, 5, 3, 7, 2, 7, 2, 3, 6, 0, 1, 7]
  list.range(0, 7)
  |> list.map(fn(x) {
    let ra =
      list.append(xs, [x])
      |> list.fold(0, fn(acc, x) { int.bitwise_shift_left(acc, 3) + x })
    run(Machine(..machine, ra:), [])
    |> list.reverse
  })
  |> print_opts

  io.println("want: 2,4,1,2,7,5,4,5,0,3,1,7,5,5,3,0")

  xs |> list.fold(0, fn(acc, x) { int.bitwise_shift_left(acc, 3) + x })
}

fn print_opts(opts) {
  opts
  |> list.index_map(fn(opt, i) {
    io.println(
      int.to_string(i)
      <> ": "
      <> opt |> list.map(int.to_string) |> string.join(with: ","),
    )
  })
}

type Machine {
  Machine(ra: Int, rb: Int, rc: Int, prog: List(Int), ip: Int)
}

fn run(machine: Machine, acc) {
  case step(machine) {
    None -> acc
    Some(#(machine, output)) ->
      case output {
        None -> run(machine, acc)
        Some(output) -> run(machine, [output, ..acc])
      }
  }
}

fn step(machine: Machine) {
  let ip = machine.ip
  let machine = Machine(..machine, ip: ip + 2)

  case machine.prog |> list.drop(ip) {
    [] -> None
    [_] -> panic
    [0, com, ..] ->
      Some(#(
        Machine(
          ..machine,
          ra: util.assert_ok(int.divide(
            machine.ra,
            int.bitwise_shift_left(1, combo_value(machine, com)),
          )),
        ),
        None,
      ))
    [1, lit, ..] ->
      Some(#(
        Machine(..machine, rb: int.bitwise_exclusive_or(machine.rb, lit)),
        None,
      ))
    [2, com, ..] ->
      Some(#(Machine(..machine, rb: combo_value(machine, com) % 8), None))
    [3, lit, ..] ->
      case machine.ra == 0 {
        True -> Some(#(machine, None))
        False -> Some(#(Machine(..machine, ip: lit), None))
      }
    [4, _, ..] ->
      Some(#(
        Machine(..machine, rb: int.bitwise_exclusive_or(machine.rb, machine.rc)),
        None,
      ))
    [5, com, ..] -> Some(#(machine, Some(combo_value(machine, com) % 8)))
    [6, com, ..] ->
      Some(#(
        Machine(
          ..machine,
          rb: util.assert_ok(int.divide(
            machine.ra,
            int.bitwise_shift_left(1, combo_value(machine, com)),
          )),
        ),
        None,
      ))
    [7, com, ..] ->
      Some(#(
        Machine(
          ..machine,
          rc: util.assert_ok(int.divide(
            machine.ra,
            int.bitwise_shift_left(1, combo_value(machine, com)),
          )),
        ),
        None,
      ))
    _ -> panic
  }
}

fn combo_value(machine: Machine, com) {
  case com {
    0 | 1 | 2 | 3 -> com
    4 -> machine.ra
    5 -> machine.rb
    6 -> machine.rc
    _ -> panic
  }
}

fn parse(lines) {
  let assert [
    "Register A: " <> ra_str,
    "Register B: " <> rb_str,
    "Register C: " <> rc_str,
    "",
    "Program: " <> prog_str,
    ..
  ] = lines

  let ra = util.must_string_to_int(ra_str)
  let rb = util.must_string_to_int(rb_str)
  let rc = util.must_string_to_int(rc_str)
  let prog =
    string.split(prog_str, on: ",") |> list.map(util.must_string_to_int)

  Machine(ra:, rb:, rc:, prog:, ip: 0)
}
