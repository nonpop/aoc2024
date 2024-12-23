import gleam/int
import gleam/list
import gleam/string
import util

pub fn solve1(lines: List(String)) -> Int {
  let stones = parse(lines)
  list.length(blink_n(stones, 25))
}

pub fn solve2(lines: List(String)) -> Int {
  todo
}

fn parse(lines) {
  let assert [line, ..] = lines

  line
  |> string.split(on: " ")
  |> list.map(util.must_string_to_int)
}

fn blink_n(stones, n) {
  case n <= 0 {
    True -> stones
    False -> blink_n(blink(stones), n - 1)
  }
}

fn blink(stones) {
  case stones {
    [] -> []
    [x, ..xs] if x == 0 -> [1, ..blink(xs)]
    [x, ..xs] ->
      case try_split(x) {
        Error(Nil) -> [x * 2024, ..blink(xs)]
        Ok(#(left, right)) -> [left, right, ..blink(xs)]
      }
  }
}

fn try_split(stone) {
  let as_string = int.to_string(stone)
  let digits = string.length(as_string)

  case digits % 2 == 0 {
    False -> Error(Nil)
    True -> {
      let left = util.must_string_to_int(string.slice(as_string, 0, digits / 2))
      let right =
        util.must_string_to_int(string.slice(as_string, digits / 2, digits / 2))

      Ok(#(left, right))
    }
  }
}
