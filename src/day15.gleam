import gleam/int
import gleam/io
import gleam/list
import gleam/string
import gleamy/set.{type Set}
import util.{type Pos, type PosOfs, Pos, PosOfs}

pub fn solve1(lines: List(String)) -> Int {
  let #(m, seq) = parse(lines)
  seq
  |> list.fold(from: m, with: step)
  |> fn(m: Map) { m.boxes |> set.to_list }
  |> list.map(fn(pos: Pos) { pos.row * 100 + pos.col })
  |> int.sum
}

pub fn solve2(lines: List(String)) -> Int {
  let #(m, seq) = parse(lines)
  let m = widen(m)

  // print_wide_map(m)

  seq
  |> list.fold(from: m, with: fn(m, s) {
    // print_step(s)
    let m = wide_step(m, s)
    // print_wide_map(m)
    m
  })
  |> fn(m: Map) { m.boxes |> set.to_list }
  |> list.map(fn(pos: Pos) { pos.row * 100 + pos.col })
  |> int.sum
}

fn widen(m: Map) {
  let bot = Pos(..m.bot, col: m.bot.col * 2)

  let walls =
    m.walls
    |> set.to_list
    |> list.flat_map(fn(pos: Pos) {
      [Pos(..pos, col: pos.col * 2), Pos(..pos, col: pos.col * 2 + 1)]
    })
    |> set.from_list(util.compare_pos)

  let boxes =
    m.boxes
    |> set.to_list
    |> list.map(fn(pos: Pos) { Pos(..pos, col: pos.col * 2) })
    |> set.from_list(util.compare_pos)

  Map(bot:, walls:, boxes:)
}

fn step(m: Map, move: Move) {
  let ofs = move_to_ofs(move)
  let new_pos = util.move(m.bot, ofs)
  case try_move_box(m, new_pos, ofs) {
    Error(Nil) -> m
    Ok(m) -> Map(..m, bot: new_pos)
  }
}

fn wide_step(m: Map, move: Move) {
  let ofs = move_to_ofs(move)
  let new_pos = util.move(m.bot, ofs)
  case set.contains(m.walls, new_pos) {
    True -> m
    False -> {
      let left_of_new_pos = Pos(..new_pos, col: new_pos.col - 1)
      case move {
        Up | Down -> {
          case set.contains(m.boxes, new_pos) {
            True ->
              case try_move_wide_box(m, new_pos, ofs) {
                Error(Nil) -> m
                Ok(m) -> Map(..m, bot: new_pos)
              }
            False -> {
              case set.contains(m.boxes, left_of_new_pos) {
                True ->
                  case try_move_wide_box(m, left_of_new_pos, ofs) {
                    Error(Nil) -> m
                    Ok(m) -> Map(..m, bot: new_pos)
                  }
                False -> Map(..m, bot: new_pos)
              }
            }
          }
        }
        Left ->
          case set.contains(m.boxes, left_of_new_pos) {
            False -> Map(..m, bot: new_pos)
            True -> {
              case try_move_wide_box(m, left_of_new_pos, ofs) {
                Error(Nil) -> m
                Ok(m) -> Map(..m, bot: new_pos)
              }
            }
          }
        Right ->
          case set.contains(m.boxes, new_pos) {
            False -> Map(..m, bot: new_pos)
            True -> {
              case try_move_wide_box(m, new_pos, ofs) {
                Error(Nil) -> m
                Ok(m) -> Map(..m, bot: new_pos)
              }
            }
          }
      }
    }
  }
}

fn try_move_box(m: Map, pos, ofs) {
  case set.contains(m.walls, pos) {
    True -> Error(Nil)
    False ->
      case set.contains(m.boxes, pos) {
        False -> Ok(m)
        True -> {
          let new_pos = util.move(pos, ofs)
          case try_move_box(m, new_pos, ofs) {
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

fn try_move_wide_box(m: Map, pos, ofs: PosOfs) {
  let new_pos = util.move(pos, ofs)
  let left_of_new_pos = Pos(..new_pos, col: new_pos.col - 1)
  let right_of_new_pos = Pos(..new_pos, col: new_pos.col + 1)

  let move_this = fn(m) {
    Ok(Map(..m, boxes: m.boxes |> set.delete(pos) |> set.insert(new_pos)))
  }

  case ofs.dcol {
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
              case try_move_wide_box(m, left_of_new_pos, ofs) {
                Error(Nil) -> Error(Nil)
                Ok(m) -> move_this(m)
              }
            False, True, False ->
              case try_move_wide_box(m, new_pos, ofs) {
                Error(Nil) -> Error(Nil)
                Ok(m) -> move_this(m)
              }
            False, False, True ->
              case try_move_wide_box(m, right_of_new_pos, ofs) {
                Error(Nil) -> Error(Nil)
                Ok(m) -> move_this(m)
              }
            True, False, True ->
              case try_move_wide_box(m, left_of_new_pos, ofs) {
                Error(Nil) -> Error(Nil)
                Ok(m) ->
                  case try_move_wide_box(m, right_of_new_pos, ofs) {
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
              case try_move_wide_box(m, left_of_new_pos, ofs) {
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
              case try_move_wide_box(m, right_of_new_pos, ofs) {
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
    from: Map(Pos(0, 0), set.new(util.compare_pos), set.new(util.compare_pos)),
    with: fn(m, line, row) { parse_map_line(m, line, row, 0) },
  )
}

fn parse_map_line(m: Map, line, row, col) {
  case line {
    [] -> m
    ["#", ..xs] ->
      parse_map_line(
        Map(..m, walls: set.insert(m.walls, Pos(row:, col:))),
        xs,
        row,
        col + 1,
      )
    ["O", ..xs] ->
      parse_map_line(
        Map(..m, boxes: set.insert(m.boxes, Pos(row:, col:))),
        xs,
        row,
        col + 1,
      )
    ["@", ..xs] ->
      parse_map_line(Map(..m, bot: Pos(row:, col:)), xs, row, col + 1)
    [".", ..xs] -> parse_map_line(m, xs, row, col + 1)
    _ -> panic
  }
}

type Move {
  Up
  Down
  Left
  Right
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
    "^" -> Up
    "v" -> Down
    "<" -> Left
    ">" -> Right
    _ -> panic
  }
}

fn move_to_ofs(move) {
  case move {
    Up -> PosOfs(drow: -1, dcol: 0)
    Down -> PosOfs(drow: 1, dcol: 0)
    Left -> PosOfs(drow: 0, dcol: -1)
    Right -> PosOfs(drow: 0, dcol: 1)
  }
}

fn print_wide_map(m: Map) {
  let max_row =
    m.walls
    |> set.to_list
    |> list.map(fn(pos: Pos) { pos.row })
    |> list.fold(0, int.max)

  let max_col =
    m.walls
    |> set.to_list
    |> list.map(fn(pos: Pos) { pos.col })
    |> list.fold(0, int.max)

  list.range(0, max_row)
  |> list.map(print_wide_row(m, max_col, _))
}

fn print_wide_row(m: Map, max_col, row) {
  list.range(0, max_col)
  |> list.map(print_wide_cell(m, row, _))

  io.println("")
}

fn print_wide_cell(m: Map, row, col) {
  let pos = Pos(row:, col:)
  case set.contains(m.walls, pos) {
    True -> io.print("#")
    False ->
      case set.contains(m.boxes, pos) {
        True -> io.print("[")
        False ->
          case set.contains(m.boxes, Pos(..pos, col: pos.col - 1)) {
            True -> io.print("]")
            False ->
              case m.bot == pos {
                True -> io.print("@")
                False -> io.print(".")
              }
          }
      }
  }
}

fn print_step(move) {
  case move {
    Up -> io.println("^")
    Down -> io.println("v")
    Left -> io.println("<")
    Right -> io.println(">")
  }
}
