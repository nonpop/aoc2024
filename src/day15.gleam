import gleam/int
import gleam/list
import gleam/string
import gleamy/set.{type Set}
import util.{type Pos, Pos, PosOfs}

pub fn solve1(lines: List(String)) -> Int {
  let #(m, seq) = parse(lines)
  seq
  |> list.fold(from: m, with: step)
  |> fn(m: Map) { m.boxes |> set.to_list }
  |> list.map(fn(pos: Pos) { pos.row * 100 + pos.col })
  |> int.sum
}

pub fn solve2(lines: List(String)) -> Int {
  todo
}

fn step(m: Map, move: Move) {
  let ofs = move_to_ofs(move)
  let new_pos = util.move(m.bot, ofs)
  case try_move_box(m, new_pos, ofs) {
    Error(Nil) -> m
    Ok(m) -> Map(..m, bot: new_pos)
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
