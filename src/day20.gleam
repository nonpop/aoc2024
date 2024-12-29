import gleam/int
import gleam/list
import gleam/string
import gleamy/map
import gleamy/set.{type Set}
import util.{type Pos, Pos}

pub fn solve1(lines: List(String)) -> Int {
  let track = parse(lines)
  let route = find_route(track, track.start, map.new(util.compare_pos))

  cheat_savings(track, route)
  |> list.filter(fn(saving) { saving >= 100 })
  |> list.length
}

pub fn solve2(lines: List(String)) -> Int {
  todo
}

fn cheat_savings(track, route) {
  route
  |> map.to_list
  |> list.flat_map(fn(start) { cheat_savings_at(track, route, start.0) })
}

fn cheat_savings_at(track, route, start) {
  [#(1, 0), #(-1, 0), #(0, 1), #(0, -1)]
  |> list.map(cheat_savings_at_dir(track, route, start, _))
}

fn cheat_savings_at_dir(track: Track, route, start: Pos, d: #(Int, Int)) {
  let assert Ok(dist_at_start) = map.get(route, start)
  let middle = Pos(row: start.row + d.0, col: start.col + d.1)
  case set.contains(track.walls, middle) {
    False -> 0
    True -> {
      let end = Pos(row: start.row + 2 * d.0, col: start.col + 2 * d.1)
      case map.get(route, end) {
        Error(Nil) -> 0
        Ok(dist_at_end) -> int.max(0, dist_at_end - dist_at_start - 2)
      }
    }
  }
}

fn find_route(track: Track, pos, acc) {
  case pos == track.end {
    True -> map.insert(acc, pos, map.count(acc))
    False -> {
      let assert [next_pos] =
        [
          Pos(..pos, row: pos.row + 1),
          Pos(..pos, row: pos.row - 1),
          Pos(..pos, col: pos.col + 1),
          Pos(..pos, col: pos.col - 1),
        ]
        |> list.filter(fn(pos) { !map.has_key(acc, pos) })
        |> list.filter(fn(pos) { !set.contains(track.walls, pos) })

      find_route(track, next_pos, map.insert(acc, pos, map.count(acc)))
    }
  }
}

type Track {
  Track(walls: Set(Pos), start: Pos, end: Pos)
}

fn parse(rows) {
  rows
  |> list.filter(fn(row) { row != "" })
  |> list.index_fold(
    from: Track(
      walls: set.new(util.compare_pos),
      start: Pos(-1, -1),
      end: Pos(-1, -1),
    ),
    with: fn(track, cells, rowi) {
      cells
      |> string.to_graphemes
      |> list.index_fold(from: track, with: fn(track, cell, coli) {
        case cell {
          "#" ->
            Track(
              ..track,
              walls: set.insert(track.walls, Pos(row: rowi, col: coli)),
            )
          "S" -> Track(..track, start: Pos(row: rowi, col: coli))
          "E" -> Track(..track, end: Pos(row: rowi, col: coli))
          "." -> track
          _ -> panic
        }
      })
    },
  )
}
