import gleam/dict
import gleam/int
import gleam/list
import gleam/pair
import gleam/string
import util

pub fn main() {
  util.run(solve1, solve2)
}

fn solve1(lines) {
  let stones = parse(lines)

  stones
  |> multiset_from_list
  |> blink_n(25)
  |> multiset_total_count
  |> util.print_int
}

fn solve2(lines) {
  let stones = parse(lines)

  stones
  |> multiset_from_list
  |> blink_n(75)
  |> multiset_total_count
  |> util.print_int
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
    False ->
      stones
      |> dict.to_list
      |> blink
      |> blink_n(n - 1)
  }
}

fn blink(stones) {
  case stones {
    [] -> dict.new()
    [#(x, c), ..xs] if x == 0 -> blink(xs) |> multiset_insert(1, c)
    [#(x, c), ..xs] ->
      case try_split(x) {
        Error(Nil) -> blink(xs) |> multiset_insert(x * 2024, c)
        Ok(#(left, right)) ->
          blink(xs) |> multiset_insert(left, c) |> multiset_insert(right, c)
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

fn multiset_from_list(xs) {
  xs
  |> list.fold(from: dict.new(), with: fn(m, x) { multiset_insert(m, x, 1) })
}

fn multiset_insert(multiset, x, count) {
  case dict.get(multiset, x) {
    Error(Nil) -> dict.insert(multiset, x, count)
    Ok(c) -> dict.insert(multiset, x, c + count)
  }
}

fn multiset_total_count(multiset) {
  multiset
  |> dict.to_list
  |> list.map(pair.second)
  |> int.sum
}
