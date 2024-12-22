import gleam/int
import gleam/io
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
  let map = parse_input(lines)
  let assert Some(#(init_pos, init_dir)) = find_guard(map, #(0, 0))
  let init_visited = set.new(compare_pos)
  let init_visited_dir = set.new(compare_pos_dir)
  let init_state = #(init_pos, init_dir, init_visited)
  let obstruction_candidates = set.delete(walk(map, init_state), init_pos)
  let total_candidates = set.count(obstruction_candidates)

  obstruction_candidates
  |> set.to_list
  |> list.index_map(fn(c, i) { #(c, i) })
  |> list.filter(fn(p) {
    let #(c, i) = p
    io.debug(int.to_string(i) <> " / " <> int.to_string(total_candidates))
    creates_loop(map, c, #(init_pos, init_dir, init_visited, init_visited_dir))
  })
  |> list.length
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

fn dir_to_int(dir) {
  case dir {
    Up -> 0
    Down -> 1
    Left -> 2
    Right -> 3
  }
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

fn compare_pos_dir(pos_dir1, pos_dir2) {
  let #(pos1, dir1) = pos_dir1
  let #(pos2, dir2) = pos_dir2

  case compare_pos(pos1, pos2) {
    order.Lt -> order.Lt
    order.Gt -> order.Gt
    order.Eq -> int.compare(dir_to_int(dir1), dir_to_int(dir2))
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

fn creates_loop(map, obstruction_pos, state) {
  let #(pos, dir, visited, visited_dir) = state

  case set.contains(visited_dir, #(pos, dir)) {
    True -> True
    False ->
      case forward_from(pos, dir) == obstruction_pos {
        True ->
          creates_loop(map, obstruction_pos, #(
            pos,
            turn_right(dir),
            visited,
            visited_dir,
          ))
        False ->
          case util.table_get(map, forward_from(pos, dir)) {
            util.TableGetRowOutOfRange | util.TableGetColOutOfRange -> False
            util.TableGetOk("#") ->
              creates_loop(map, obstruction_pos, #(
                pos,
                turn_right(dir),
                visited,
                visited_dir,
              ))
            util.TableGetOk(_) ->
              creates_loop(map, obstruction_pos, #(
                forward_from(pos, dir),
                dir,
                set.insert(visited, pos),
                set.insert(visited_dir, #(pos, dir)),
              ))
          }
      }
  }
}
