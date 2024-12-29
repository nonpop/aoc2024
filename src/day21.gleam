import gleam/int
import gleam/list
import gleam/order
import gleam/pair
import gleam/string
import util.{type Pos, Pos}

pub fn solve1(lines: List(String)) -> Int {
  let steppers = [
    #("A", numeric_step, numeric_pos),
    #("A", directional_step, directional_pos),
    #("A", directional_step, directional_pos),
  ]

  lines
  |> list.filter(fn(line) { line != "" })
  |> list.map(string.to_graphemes)
  |> list.map(fn(code) {
    let best_seq = shortest_expansion(code, steppers)
    complexity(code, best_seq)
  })
  |> int.sum
}

pub fn solve2(lines: List(String)) -> Int {
  todo
}

fn complexity(code, seq) {
  let code_numeric =
    code
    |> string.join(with: "")
    |> string.drop_end(1)
    |> int.parse
    |> util.assert_ok

  string.length(seq) * code_numeric
}

fn shortest_expansion(positions, steppers) {
  case positions, steppers {
    [], _ -> ""
    ps, [] -> string.join(ps, with: "")
    [p, ..ps], [#(start, step, to_pos), ..steppers] -> {
      let step1 =
        sequences(to_pos(start), step, to_pos(p))
        |> list.map(string.to_graphemes)
        |> list.map(shortest_expansion(_, steppers))
        |> list.sort(fn(a, b) {
          int.compare(string.length(a), string.length(b))
        })
        |> list.first
        |> util.assert_ok

      step1 <> shortest_expansion(ps, [#(p, step, to_pos), ..steppers])
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
      #("v", Pos(..from, row: from.row + 1)),
      #(">", Pos(..from, col: from.col + 1)),
    ]
    order.Lt, order.Eq -> [#("v", Pos(..from, row: from.row + 1))]
    order.Lt, order.Gt -> [
      #("v", Pos(..from, row: from.row + 1)),
      #("<", Pos(..from, col: from.col - 1)),
    ]
    order.Eq, order.Lt -> [#(">", Pos(..from, col: from.col + 1))]
    order.Eq, order.Eq -> []
    order.Eq, order.Gt -> [#("<", Pos(..from, col: from.col - 1))]
    order.Gt, order.Lt -> [
      #("^", Pos(..from, row: from.row - 1)),
      #(">", Pos(..from, col: from.col + 1)),
    ]
    order.Gt, order.Eq -> [#("^", Pos(..from, row: from.row - 1))]
    order.Gt, order.Gt -> [
      #("^", Pos(..from, row: from.row - 1)),
      #("<", Pos(..from, col: from.col - 1)),
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
      #("v", Pos(..from, row: from.row + 1)),
      #(">", Pos(..from, col: from.col + 1)),
    ]
    order.Lt, order.Eq -> [#("v", Pos(..from, row: from.row + 1))]
    order.Lt, order.Gt -> [
      #("v", Pos(..from, row: from.row + 1)),
      #("<", Pos(..from, col: from.col - 1)),
    ]
    order.Eq, order.Lt -> [#(">", Pos(..from, col: from.col + 1))]
    order.Eq, order.Eq -> []
    order.Eq, order.Gt -> [#("<", Pos(..from, col: from.col - 1))]
    order.Gt, order.Lt -> [
      #("^", Pos(..from, row: from.row - 1)),
      #(">", Pos(..from, col: from.col + 1)),
    ]
    order.Gt, order.Eq -> [#("^", Pos(..from, row: from.row - 1))]
    order.Gt, order.Gt -> [
      #("^", Pos(..from, row: from.row - 1)),
      #("<", Pos(..from, col: from.col - 1)),
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
