import gleam/int
import gleam/list
import gleam/string
import gleamy/map
import util

pub fn solve1(lines: List(String)) -> Int {
  let stones = parse(lines)
  stones
  |> mset_from_list
  |> blink_n(25)
  |> mset_total_count
}

pub fn solve2(lines: List(String)) -> Int {
  let stones = parse(lines)
  stones
  |> mset_from_list
  |> blink_n(75)
  |> mset_total_count
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
      |> map.to_list
      |> blink
      |> blink_n(n - 1)
  }
}

fn blink(stones) {
  case stones {
    [] -> map.new(int.compare)
    [#(x, c), ..xs] if x == 0 -> blink(xs) |> mset_insert(1, c)
    [#(x, c), ..xs] ->
      case try_split(x) {
        Error(Nil) -> blink(xs) |> mset_insert(x * 2024, c)
        Ok(#(left, right)) ->
          blink(xs) |> mset_insert(left, c) |> mset_insert(right, c)
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

fn mset_from_list(xs) {
  xs
  |> list.fold(from: map.new(int.compare), with: fn(m, x) {
    mset_insert(m, x, 1)
  })
}

fn mset_insert(mset, x, count) {
  case map.get(mset, x) {
    Error(Nil) -> map.insert(mset, x, count)
    Ok(c) -> map.insert(mset, x, c + count)
  }
}

fn mset_total_count(mset) {
  mset
  |> map.to_list
  |> list.map(fn(p) { p.1 })
  |> int.sum
}
