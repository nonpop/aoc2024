import gleam/dict
import gleam/int
import gleam/list
import gleam/order
import gleam/pair
import gleam/string
import ref
import util.{type Pos, Pos}

pub fn main() {
  util.run(solve1, solve2)
}

fn solve1(lines) {
  let steppers = [
    #("A", numeric_step, numeric_pos),
    #("A", directional_step, directional_pos),
    #("A", directional_step, directional_pos),
  ]

  lines
  |> list.filter(fn(line) { line != "" })
  |> list.map(string.to_graphemes)
  |> list.map(fn(code) {
    let best_seq_len =
      shortest_expansion_len(ref.cell(dict.new()), code, steppers)
    complexity(code, best_seq_len)
  })
  |> int.sum
  |> util.print_int
}

fn solve2(lines) {
  let steppers = [
    #("A", numeric_step, numeric_pos),
    ..list.repeat(#("A", directional_step, directional_pos), 25)
  ]

  lines
  |> list.filter(fn(line) { line != "" })
  |> list.map(string.to_graphemes)
  |> list.map(fn(code) {
    let best_seq_len =
      shortest_expansion_len(ref.cell(dict.new()), code, steppers)
    complexity(code, best_seq_len)
  })
  |> int.sum
  |> util.print_int
}

fn complexity(code, seq_len) {
  let code_numeric =
    code
    |> string.join(with: "")
    |> string.drop_end(1)
    |> int.parse
    |> util.assert_ok

  seq_len * code_numeric
}

fn shortest_expansion_len(cache, positions, steppers) {
  let steppers_key = steppers |> list.map(fn(p: #(_, _, _)) { p.0 })
  let cache_key = #(string.join(positions, with: ""), steppers_key)
  case dict.get(ref.get(cache), cache_key) {
    Ok(result) -> result
    Error(Nil) ->
      case positions, steppers {
        [], _ -> 0
        ps, [] -> list.length(ps)
        [p, ..ps], [#(start, step, to_pos), ..steppers] -> {
          let step1 =
            sequences(to_pos(start), step, to_pos(p))
            |> list.map(string.to_graphemes)
            |> list.map(shortest_expansion_len(cache, _, steppers))
            |> list.sort(int.compare)
            |> list.first
            |> util.assert_ok

          let result =
            step1
            + shortest_expansion_len(cache, ps, [#(p, step, to_pos), ..steppers])

          ref.set(cache, fn(cache) { dict.insert(cache, cache_key, result) })

          result
        }
      }
  }
}

fn sequences(from, step, to) {
  sequences_loop([#("", from)], step, to, dist(from, to))
  |> list.map(pair.first)
}

fn sequences_loop(from: List(#(String, Pos)), step, to, dist) {
  case dist <= 0 {
    True -> from |> list.map(fn(p) { #(p.0 <> "A", p.1) })
    False ->
      from
      |> list.flat_map(fn(p) {
        step(p.1, to)
        |> list.map(fn(q: #(_, _)) { #(p.0 <> q.0, q.1) })
      })
      |> sequences_loop(step, to, dist - 1)
  }
}

fn numeric_step(from: Pos, to: Pos) {
  let maybe_next = case
    int.compare(from.row, to.row),
    int.compare(from.col, to.col)
  {
    order.Lt, order.Lt -> [
      #("v", util.move(from, util.down)),
      #(">", util.move(from, util.right)),
    ]
    order.Lt, order.Eq -> [#("v", util.move(from, util.down))]
    order.Lt, order.Gt -> [
      #("v", util.move(from, util.down)),
      #("<", util.move(from, util.left)),
    ]
    order.Eq, order.Lt -> [#(">", util.move(from, util.right))]
    order.Eq, order.Eq -> []
    order.Eq, order.Gt -> [#("<", util.move(from, util.left))]
    order.Gt, order.Lt -> [
      #("^", util.move(from, util.up)),
      #(">", util.move(from, util.right)),
    ]
    order.Gt, order.Eq -> [#("^", util.move(from, util.up))]
    order.Gt, order.Gt -> [
      #("^", util.move(from, util.up)),
      #("<", util.move(from, util.left)),
    ]
  }
  maybe_next
  |> list.filter(fn(step) { step.1 != Pos(row: 3, col: 0) })
}

fn numeric_pos(button) {
  case button {
    "7" -> Pos(row: 0, col: 0)
    "8" -> Pos(row: 0, col: 1)
    "9" -> Pos(row: 0, col: 2)
    "4" -> Pos(row: 1, col: 0)
    "5" -> Pos(row: 1, col: 1)
    "6" -> Pos(row: 1, col: 2)
    "1" -> Pos(row: 2, col: 0)
    "2" -> Pos(row: 2, col: 1)
    "3" -> Pos(row: 2, col: 2)
    "0" -> Pos(row: 3, col: 1)
    "A" -> Pos(row: 3, col: 2)
    _ -> panic
  }
}

fn directional_step(from: Pos, to: Pos) {
  let maybe_next = case
    int.compare(from.row, to.row),
    int.compare(from.col, to.col)
  {
    order.Lt, order.Lt -> [
      #("v", util.move(from, util.down)),
      #(">", util.move(from, util.right)),
    ]
    order.Lt, order.Eq -> [#("v", util.move(from, util.down))]
    order.Lt, order.Gt -> [
      #("v", util.move(from, util.down)),
      #("<", util.move(from, util.left)),
    ]
    order.Eq, order.Lt -> [#(">", util.move(from, util.right))]
    order.Eq, order.Eq -> []
    order.Eq, order.Gt -> [#("<", util.move(from, util.left))]
    order.Gt, order.Lt -> [
      #("^", util.move(from, util.up)),
      #(">", util.move(from, util.right)),
    ]
    order.Gt, order.Eq -> [#("^", util.move(from, util.up))]
    order.Gt, order.Gt -> [
      #("^", util.move(from, util.up)),
      #("<", util.move(from, util.left)),
    ]
  }
  maybe_next
  |> list.filter(fn(step) { step.1 != Pos(row: 0, col: 0) })
}

fn directional_pos(button) {
  case button {
    "^" -> Pos(row: 0, col: 1)
    "A" -> Pos(row: 0, col: 2)
    "<" -> Pos(row: 1, col: 0)
    "v" -> Pos(row: 1, col: 1)
    ">" -> Pos(row: 1, col: 2)
    _ -> panic
  }
}

fn dist(from: Pos, to: Pos) {
  int.absolute_value(from.row - to.row) + int.absolute_value(from.col - to.col)
}
