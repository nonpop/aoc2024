import gleam/dict
import gleam/int
import gleam/list
import gleam/set
import util

pub fn solve1(lines: List(String)) -> Int {
  parse(lines)
  |> list.map(generate(_, 2000))
  |> int.sum
}

pub fn solve2(lines: List(String)) -> Int {
  let seqs_to_prices =
    parse(lines)
    |> list.map(generate_prices(_, 2000, []))
    |> list.map(changes)
    |> list.map(change_sequences)
    |> list.map(list.reverse)
    |> list.map(dict.from_list)

  let all_seqs =
    seqs_to_prices
    |> list.flat_map(dict.keys)
    |> set.from_list
    |> set.to_list

  all_seqs
  |> list.map(seq_total_price(seqs_to_prices, _))
  |> max
}

fn max(xs) {
  case xs {
    [] -> panic
    [x] -> x
    [x, y, ..xs] -> max([int.max(x, y), ..xs])
  }
}

fn seq_total_price(seqs_to_prices, seq) {
  seqs_to_prices
  |> list.filter_map(dict.get(_, seq))
  |> int.sum
}

fn change_sequences(changes) {
  changes
  |> list.zip(list.drop(changes, 1))
  |> list.zip(list.drop(changes, 2))
  |> list.zip(list.drop(changes, 3))
  |> list.map(fn(t: #(#(#(#(_, _), _), _), _)) {
    #(#(t.0.0.0.0, t.0.0.1.0, t.0.1.0, t.1.0), t.1.1)
  })
}

fn changes(secrets) {
  secrets
  |> list.zip(list.drop(secrets, 1))
  |> list.map(fn(p) { #(p.1 - p.0, p.1) })
}

fn generate_prices(seed, n, acc) {
  case n <= 0 {
    True -> list.reverse([seed % 10, ..acc])
    False -> generate_prices(step(seed), n - 1, [seed % 10, ..acc])
  }
}

fn generate(seed, n) {
  case n <= 0 {
    True -> seed
    False -> generate(step(seed), n - 1)
  }
}

fn step(seed) {
  let s1 = int.bitwise_exclusive_or(seed * 64, seed) % 16_777_216
  let s2 = int.bitwise_exclusive_or(s1 / 32, s1) % 16_777_216
  let s3 = int.bitwise_exclusive_or(s2 * 2048, s2) % 16_777_216
  s3
}

fn parse(lines) {
  lines
  |> list.filter(fn(line) { line != "" })
  |> list.map(util.must_string_to_int)
}
