import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/order
import gleam/string
import gleamy/set
import glearray
import util

pub fn solve1(lines: List(String)) -> Int {
  let map = parse_input(lines)
  let assert Some(#(init_pos, init_dir)) = find_guard(map, #(0, 0))
  let init_visited = set.new(compare_pos)
  let init_state = #(init_pos, init_dir, init_visited)

  set.count(walk(map, init_state))
}

pub fn solve2(lines: List(String)) -> Int {
  todo
}

fn parse_input(lines) {
  lines
  |> list.filter(fn(line) { line != "" })
  |> list.map(fn(line) { line |> string.to_graphemes |> glearray.from_list })
  |> glearray.from_list
}

fn find_guard(map, pos) {
  let #(rowi, coli) = pos

  case util.table_get(map, pos) {
    util.TableGetOk("^") -> Some(#(pos, Up))
    util.TableGetOk(_) -> find_guard(map, #(rowi, coli + 1))
    util.TableGetColOutOfRange -> find_guard(map, #(rowi + 1, 0))
    util.TableGetRowOutOfRange -> None
  }
}

type Dir {
  Up
  Down
  Left
  Right
}

fn compare_pos(pos1, pos2) {
  let #(row1, col1) = pos1
  let #(row2, col2) = pos2

  case int.compare(row1, row2) {
    order.Lt -> order.Lt
    order.Gt -> order.Gt
    order.Eq -> int.compare(col1, col2)
  }
}

fn walk(map, state) {
  let #(pos, dir, visited) = state

  case util.table_get(map, forward_from(pos, dir)) {
    util.TableGetRowOutOfRange | util.TableGetColOutOfRange ->
      set.insert(visited, pos)
    util.TableGetOk("#") -> walk(map, #(pos, turn_right(dir), visited))
    util.TableGetOk(_) ->
      walk(map, #(forward_from(pos, dir), dir, set.insert(visited, pos)))
  }
}

fn forward_from(pos, dir) {
  let #(row, col) = pos
  let #(row_ofs, col_ofs) = dir_ofs(dir)

  #(row + row_ofs, col + col_ofs)
}

fn dir_ofs(dir) {
  case dir {
    Up -> #(-1, 0)
    Down -> #(1, 0)
    Left -> #(0, -1)
    Right -> #(0, 1)
  }
}

fn turn_right(dir) {
  case dir {
    Up -> Right
    Right -> Down
    Down -> Left
    Left -> Up
  }
}
