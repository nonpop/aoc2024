import gleam/int
import gleam/list
import gleam/set.{type Set}
import gleam/string
import util.{type Dir, type Pos, Dir, Pos}

pub fn main() {
  util.run(solve1, solve2)
}

fn solve1(lines) {
  let #(m, seq) = parse(lines)

  seq
  |> list.fold(from: m, with: step)
  |> fn(m: Map) { m.boxes |> set.to_list }
  |> list.map(fn(pos: Pos) { pos.row * 100 + pos.col })
  |> int.sum
  |> util.print_int
}

fn solve2(lines) {
  let #(m, seq) = parse(lines)
  let m = widen(m)

  seq
  |> list.fold(from: m, with: wide_step)
  |> fn(m: Map) { m.boxes |> set.to_list }
  |> list.map(fn(pos: Pos) { pos.row * 100 + pos.col })
  |> int.sum
  |> util.print_int
}

fn widen(m: Map) {
  let bot = Pos(..m.bot, col: m.bot.col * 2)

  let walls =
    m.walls
    |> set.to_list
    |> list.flat_map(fn(pos: Pos) {
      [Pos(..pos, col: pos.col * 2), Pos(..pos, col: pos.col * 2 + 1)]
    })
    |> set.from_list()

  let boxes =
    m.boxes
    |> set.to_list
    |> list.map(fn(pos: Pos) { Pos(..pos, col: pos.col * 2) })
    |> set.from_list()

  Map(bot:, walls:, boxes:)
}

fn step(m: Map, dir: Dir) {
  let new_pos = util.move(m.bot, dir)
  case try_move_box(m, new_pos, dir) {
    Error(Nil) -> m
    Ok(m) -> Map(..m, bot: new_pos)
  }
}

fn wide_step(m: Map, dir: Dir) {
  let new_pos = util.move(m.bot, dir)
  case set.contains(m.walls, new_pos) {
    True -> m
    False -> {
      let left_of_new_pos = util.move(new_pos, util.left)
      case dir.dcol {
        0 -> {
          case set.contains(m.boxes, new_pos) {
            True ->
              case try_move_wide_box(m, new_pos, dir) {
                Error(Nil) -> m
                Ok(m) -> Map(..m, bot: new_pos)
              }
            False -> {
              case set.contains(m.boxes, left_of_new_pos) {
                True ->
                  case try_move_wide_box(m, left_of_new_pos, dir) {
                    Error(Nil) -> m
                    Ok(m) -> Map(..m, bot: new_pos)
                  }
                False -> Map(..m, bot: new_pos)
              }
            }
          }
        }
        -1 ->
          case set.contains(m.boxes, left_of_new_pos) {
            False -> Map(..m, bot: new_pos)
            True -> {
              case try_move_wide_box(m, left_of_new_pos, dir) {
                Error(Nil) -> m
                Ok(m) -> Map(..m, bot: new_pos)
              }
            }
          }
        1 ->
          case set.contains(m.boxes, new_pos) {
            False -> Map(..m, bot: new_pos)
            True -> {
              case try_move_wide_box(m, new_pos, dir) {
                Error(Nil) -> m
                Ok(m) -> Map(..m, bot: new_pos)
              }
            }
          }
        _ -> panic
      }
    }
  }
}

fn try_move_box(m: Map, pos, dir) {
  case set.contains(m.walls, pos) {
    True -> Error(Nil)
    False ->
      case set.contains(m.boxes, pos) {
        False -> Ok(m)
        True -> {
          let new_pos = util.move(pos, dir)
          case try_move_box(m, new_pos, dir) {
            Error(Nil) -> Error(Nil)
            Ok(m) ->
              Ok(
                Map(
                  ..m,
                  boxes: m.boxes
                    |> set.delete(pos)
                    |> set.insert(new_pos),
                ),
              )
          }
        }
      }
  }
}

fn try_move_wide_box(m: Map, pos, dir: Dir) {
  let new_pos = util.move(pos, dir)
  let left_of_new_pos = util.move(new_pos, util.left)
  let right_of_new_pos = util.move(new_pos, util.right)

  let move_this = fn(m) {
    Ok(Map(..m, boxes: m.boxes |> set.delete(pos) |> set.insert(new_pos)))
  }

  case dir.dcol {
    0 ->
      case
        set.contains(m.walls, new_pos)
        || set.contains(m.walls, right_of_new_pos)
      {
        True -> Error(Nil)
        False ->
          case
            set.contains(m.boxes, left_of_new_pos),
            set.contains(m.boxes, new_pos),
            set.contains(m.boxes, right_of_new_pos)
          {
            False, False, False -> move_this(m)
            True, False, False ->
              case try_move_wide_box(m, left_of_new_pos, dir) {
                Error(Nil) -> Error(Nil)
                Ok(m) -> move_this(m)
              }
            False, True, False ->
              case try_move_wide_box(m, new_pos, dir) {
                Error(Nil) -> Error(Nil)
                Ok(m) -> move_this(m)
              }
            False, False, True ->
              case try_move_wide_box(m, right_of_new_pos, dir) {
                Error(Nil) -> Error(Nil)
                Ok(m) -> move_this(m)
              }
            True, False, True ->
              case try_move_wide_box(m, left_of_new_pos, dir) {
                Error(Nil) -> Error(Nil)
                Ok(m) ->
                  case try_move_wide_box(m, right_of_new_pos, dir) {
                    Error(Nil) -> Error(Nil)
                    Ok(m) -> move_this(m)
                  }
              }
            // impossible cases:
            True, True, False -> panic
            False, True, True -> panic
            True, True, True -> panic
          }
      }
    -1 ->
      case set.contains(m.walls, new_pos) {
        True -> Error(Nil)
        False ->
          case set.contains(m.boxes, left_of_new_pos) {
            False -> move_this(m)
            True -> {
              case try_move_wide_box(m, left_of_new_pos, dir) {
                Error(Nil) -> Error(Nil)
                Ok(m) -> move_this(m)
              }
            }
          }
      }
    1 -> {
      case set.contains(m.walls, right_of_new_pos) {
        True -> Error(Nil)
        False ->
          case set.contains(m.boxes, right_of_new_pos) {
            False -> move_this(m)
            True -> {
              case try_move_wide_box(m, right_of_new_pos, dir) {
                Error(Nil) -> Error(Nil)
                Ok(m) -> move_this(m)
              }
            }
          }
      }
    }
    _ -> panic
  }
}

fn parse(lines) {
  let assert [map_str, seq_str, ..] =
    lines |> string.join(with: "\n") |> string.split(on: "\n\n")

  #(parse_map(map_str), parse_seq(seq_str))
}

type Map {
  Map(bot: Pos, walls: Set(Pos), boxes: Set(Pos))
}

fn parse_map(str) {
  str
  |> string.split(on: "\n")
  |> list.filter(fn(line) { line != "" })
  |> list.map(string.to_graphemes)
  |> list.index_fold(
    from: Map(Pos(0, 0), set.new(), set.new()),
    with: fn(m, line, row) { parse_map_line(m, line, Pos(row:, col: 0)) },
  )
}

fn parse_map_line(m: Map, line, pos) {
  case line {
    [] -> m
    ["#", ..xs] ->
      parse_map_line(
        Map(..m, walls: set.insert(m.walls, pos)),
        xs,
        util.next_col(pos),
      )
    ["O", ..xs] ->
      parse_map_line(
        Map(..m, boxes: set.insert(m.boxes, pos)),
        xs,
        util.next_col(pos),
      )
    ["@", ..xs] -> parse_map_line(Map(..m, bot: pos), xs, util.next_col(pos))
    [".", ..xs] -> parse_map_line(m, xs, util.next_col(pos))
    _ -> panic
  }
}

fn parse_seq(str) {
  str
  |> string.split(on: "\n")
  |> list.filter(fn(line) { line != "" })
  |> string.join(with: "")
  |> string.to_graphemes
  |> list.map(parse_move)
}

fn parse_move(c) {
  case c {
    "^" -> util.up
    "v" -> util.down
    "<" -> util.left
    ">" -> util.right
    _ -> panic
  }
}
