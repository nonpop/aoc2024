import gleam/dict
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleam/string

pub fn solve1(lines: List(String)) -> Int {
  let #(starts, wirings, ends) = parse(lines)

  let states =
    ends
    |> list.fold(starts, fn(states, end) {
      determine_output(states, wirings, end)
    })

  ends
  |> list.reverse
  |> list.map(fn(end) {
    let assert Ok(state) = dict.get(states, end)
    state
  })
  |> list.fold(0, fn(res, bit) {
    case bit {
      True -> res * 2 + 1
      False -> res * 2
    }
  })
}

pub fn solve2(lines: List(String)) -> Int {
  todo
}

fn determine_output(states, wirings, out) {
  case dict.get(states, out) {
    Ok(_) -> states
    Error(Nil) -> {
      let assert Ok(Wiring(i1:, i2:, op:, ..)) = dict.get(wirings, out)
      let states = determine_output(states, wirings, i1)
      let states = determine_output(states, wirings, i2)
      let assert Ok(i1_state) = dict.get(states, i1)
      let assert Ok(i2_state) = dict.get(states, i2)

      let o_state = case op {
        And -> i1_state && i2_state
        Or -> i1_state || i2_state
        Xor -> i1_state != i2_state
      }

      dict.insert(states, out, o_state)
    }
  }
}

fn parse(lines) {
  let assert [starts_str, wirings_str, ..] =
    lines
    |> string.join(with: "\n")
    |> string.split(on: "\n\n")

  let starts =
    starts_str
    |> string.split("\n")
    |> list.filter(fn(line) { line != "" })
    |> list.map(fn(start_str) {
      let assert [input, val_str] = string.split(start_str, on: ": ")
      let val = case val_str {
        "0" -> False
        "1" -> True
        _ -> panic
      }
      #(input, val)
    })
    |> dict.from_list

  let wirings =
    wirings_str
    |> string.split(on: "\n")
    |> list.filter(fn(line) { line != "" })
    |> list.map(parse_wiring)
    |> list.map(fn(w) { #(w.o, w) })
    |> dict.from_list

  let ends =
    wirings
    |> dict.keys
    |> list.filter_map(fn(o) {
      case o {
        "z" <> _ -> Ok(o)
        _ -> Error(Nil)
      }
    })
    |> list.sort(string.compare)

  #(starts, wirings, ends)
}

fn parse_wiring(wiring_str) {
  let assert Ok(re) = regexp.from_string("(\\w+) (AND|OR|XOR) (\\w+) -> (\\w+)")
  let assert [
    regexp.Match(
      submatches: [Some(i1), Some(op_str), Some(i2), Some(o)],
      ..,
    ),
  ] = regexp.scan(re, wiring_str)

  let op = case op_str {
    "AND" -> And
    "OR" -> Or
    "XOR" -> Xor
    _ -> panic
  }

  Wiring(i1:, i2:, op:, o:)
}

type Op {
  And
  Or
  Xor
}

type Wiring {
  Wiring(i1: String, i2: String, op: Op, o: String)
}
