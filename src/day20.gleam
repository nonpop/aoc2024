import gleam/int
import gleam/io
import gleam/list
import gleam/string
import gleamy/map
import gleamy/set.{type Set}
import util.{type Pos, Pos}

pub fn solve1(lines: List(String)) -> Int {
  let track = parse(lines)
  let route = find_route(track, track.start, map.new(util.compare_pos))

  cheat_savings(route, 2)
  |> list.filter(fn(saving) { saving >= 100 })
  |> list.length
}

pub fn solve2(lines: List(String)) -> Int {
  let track = parse(lines)
  let route = find_route(track, track.start, map.new(util.compare_pos))

  cheat_savings(route, 20)
  |> list.filter(fn(saving) { saving >= 100 })
  |> list.length
}

fn cheat_savings(route, max_dist) {
  route
  |> map.to_list
  |> list.flat_map(fn(start) {
    cheat_savings_at(route, io.debug(start.0), max_dist)
  })
}

fn cheat_savings_at(route, start, max_dist) {
  let assert Ok(dist_at_start) = map.get(route, start)

  positions_at_max_dist(start, max_dist)
  |> set.to_list
  |> list.map(fn(end) {
    case map.get(route, end) {
      Error(Nil) -> 0
      Ok(dist_at_end) -> dist_at_end - dist_at_start - dist(start, end)
    }
  })
  |> list.filter(fn(saving) { saving > 0 })
}

fn positions_at_max_dist(pos: Pos, max_dist) {
  list.range(0, max_dist)
  |> list.fold(set.new(util.compare_pos), fn(acc, dist) {
    set.union(acc, positions_at_dist(pos, dist))
  })
}

fn positions_at_dist(pos: Pos, dist) {
  list.range(0, dist)
  |> list.flat_map(fn(d) {
    [
      Pos(row: pos.row + d, col: pos.col + dist - d),
      Pos(row: pos.row - d, col: pos.col + dist - d),
      Pos(row: pos.row + d, col: pos.col - dist + d),
      Pos(row: pos.row - d, col: pos.col - dist + d),
    ]
  })
  |> set.from_list(util.compare_pos)
}

fn dist(start: Pos, end: Pos) {
  int.absolute_value(start.row - end.row)
  + int.absolute_value(start.col - end.col)
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
