import argv
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import glearray
import simplifile

pub fn run(solve1: fn(_) -> Nil, solve2: fn(_) -> Nil) {
  let #(solver, filename) = case argv.load().arguments {
    ["1", filename] -> #(solve1, filename)
    ["2", filename] -> #(solve2, filename)
    _ -> panic
  }

  let assert Ok(content) = simplifile.read("inputs/" <> filename)
  let lines = string.split(content, on: "\n")

  solver(lines)
}

pub fn print_int(i) {
  i |> int.to_string |> io.println
}

pub fn assert_ok(result) {
  let assert Ok(value) = result
  value
}

pub fn must_string_to_int(s) {
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

pub fn next_col(pos: Pos) {
  Pos(..pos, col: pos.col + 1)
}

pub fn next_row(pos: Pos) {
  Pos(row: pos.row + 1, col: 0)
}

pub type Dir {
  Dir(drow: Int, dcol: Int)
}

pub const up = Dir(-1, 0)

pub const down = Dir(1, 0)

pub const left = Dir(0, -1)

pub const right = Dir(0, 1)

pub const up_left = Dir(-1, -1)

pub const up_right = Dir(-1, 1)

pub const down_left = Dir(1, -1)

pub const down_right = Dir(1, 1)

pub fn move(pos: Pos, dir: Dir) {
  Pos(row: pos.row + dir.drow, col: pos.col + dir.dcol)
}

pub fn turn_right(dir: Dir) {
  Dir(drow: dir.dcol, dcol: -dir.drow)
}

pub fn turn_left(dir: Dir) {
  Dir(drow: -dir.dcol, dcol: dir.drow)
}

pub fn map_array(a, f) {
  a
  |> glearray.to_list
  |> list.map(f)
  |> glearray.from_list
}

pub fn map_table(table, f) {
  map_array(table, fn(row) { map_array(row, f) })
}
