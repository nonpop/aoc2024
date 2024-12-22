import gleam/int
import gleam/list
import gleam/order.{type Order}
import gleam/string
import gleamy/map
import glearray

pub fn assert_ok(result) {
  let assert Ok(value) = result
  value
}

pub fn must_string_to_int(s: String) -> Int {
  s |> int.parse |> assert_ok
}

pub fn parse_table(lines) {
  let lines =
    lines
    |> list.filter(fn(line) { line != "" })

  let num_rows = list.length(lines)
  let num_cols = case lines {
    [] -> 0
    [row, ..] -> string.length(row)
  }

  let table =
    lines
    |> list.map(fn(line) { line |> string.to_graphemes |> glearray.from_list })
    |> glearray.from_list

  #(table, num_rows, num_cols)
}

pub type TableGetResult(t) {
  TableGetOk(t)
  TableGetRowOutOfRange
  TableGetColOutOfRange
}

pub fn table_get(table, pos: Pos) {
  case glearray.get(table, pos.row) {
    Error(Nil) -> TableGetRowOutOfRange
    Ok(row) ->
      case glearray.get(row, pos.col) {
        Error(Nil) -> TableGetColOutOfRange
        Ok(value) -> TableGetOk(value)
      }
  }
}

pub type Pos {
  Pos(row: Int, col: Int)
}

pub fn compare_pos(a: Pos, b: Pos) -> Order {
  case int.compare(a.row, b.row) {
    order.Lt -> order.Lt
    order.Gt -> order.Gt
    order.Eq -> int.compare(a.col, b.col)
  }
}

pub fn map_values(m, f, compare_keys) {
  m
  |> map.to_list
  |> list.map(fn(kv) { #(kv.0, f(kv)) })
  |> map.from_list(compare_keys)
}
