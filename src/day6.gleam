import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/set
import util.{type Pos, Pos}

pub fn main() {
  util.run(solve1, solve2)
}

fn solve1(lines) {
  let #(map, _, _) = util.parse_table(lines)
  let assert Some(#(init_pos, init_dir)) = find_guard(map, Pos(0, 0))
  let init_visited = set.new()
  let init_state = #(init_pos, init_dir, init_visited)

  set.size(walk(map, init_state))
  |> util.print_int
}

fn solve2(lines) {
  // slow but <1min

  let #(map, _, _) = util.parse_table(lines)
  let assert Some(#(init_pos, init_dir)) = find_guard(map, Pos(0, 0))
  let init_visited = set.new()
  let init_visited_dir = set.new()
  let init_state = #(init_pos, init_dir, init_visited)
  let obstruction_candidates = set.delete(walk(map, init_state), init_pos)
  let total_candidates = set.size(obstruction_candidates)

  obstruction_candidates
  |> set.to_list
  |> list.index_map(fn(c, i) { #(c, i) })
  |> list.filter(fn(p) {
    case p.1 % 100 == 0 {
      True ->
        io.println(
          int.to_string(p.1) <> " / " <> int.to_string(total_candidates),
        )
      False -> Nil
    }
    creates_loop(map, p.0, #(init_pos, init_dir, init_visited, init_visited_dir))
  })
  |> list.length
  |> util.print_int
}

fn find_guard(map, pos) {
  case util.table_get(map, pos) {
    util.TableGetOk("^") -> Some(#(pos, util.up))
    util.TableGetOk(_) -> find_guard(map, util.next_col(pos))
    util.TableGetColOutOfRange -> find_guard(map, util.next_row(pos))
    util.TableGetRowOutOfRange -> None
  }
}

fn walk(map, state) {
  let #(pos, dir, visited) = state

  case util.table_get(map, util.move(pos, dir)) {
    util.TableGetRowOutOfRange | util.TableGetColOutOfRange ->
      set.insert(visited, pos)
    util.TableGetOk("#") -> walk(map, #(pos, util.turn_right(dir), visited))
    util.TableGetOk(_) ->
      walk(map, #(util.move(pos, dir), dir, set.insert(visited, pos)))
  }
}

fn creates_loop(map, obstruction_pos, state) {
  let #(pos, dir, visited, visited_dir) = state

  case set.contains(visited_dir, #(pos, dir)) {
    True -> True
    False ->
      case util.move(pos, dir) == obstruction_pos {
        True ->
          creates_loop(map, obstruction_pos, #(
            pos,
            util.turn_right(dir),
            visited,
            visited_dir,
          ))
        False ->
          case util.table_get(map, util.move(pos, dir)) {
            util.TableGetRowOutOfRange | util.TableGetColOutOfRange -> False
            util.TableGetOk("#") ->
              creates_loop(map, obstruction_pos, #(
                pos,
                util.turn_right(dir),
                visited,
                visited_dir,
              ))
            util.TableGetOk(_) ->
              creates_loop(map, obstruction_pos, #(
                util.move(pos, dir),
                dir,
                set.insert(visited, pos),
                set.insert(visited_dir, #(pos, dir)),
              ))
          }
      }
  }
}
