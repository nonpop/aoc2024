import gleam/dict
import gleam/int
import gleam/list
import gleam/set.{type Set}
import gleam/string
import util.{type Pos, Pos}

pub fn main() {
  util.run(solve1, solve2)
}

fn solve1(lines) {
  let track = parse(lines)
  let route = find_route(track, track.start, dict.new())

  cheat_savings(route, 2)
  |> list.filter(fn(saving) { saving >= 100 })
  |> list.length
  |> util.print_int
}

fn solve2(lines) {
  let track = parse(lines)
  let route = find_route(track, track.start, dict.new())

  cheat_savings(route, 20)
  |> list.filter(fn(saving) { saving >= 100 })
  |> list.length
  |> util.print_int
}

fn cheat_savings(route, max_dist) {
  route
  |> dict.keys
  |> list.flat_map(cheat_savings_at(route, _, max_dist))
}

fn cheat_savings_at(route, start, max_dist) {
  let assert Ok(dist_at_start) = dict.get(route, start)

  positions_at_max_dist(start, max_dist)
  |> set.to_list
  |> list.map(fn(end) {
    case dict.get(route, end) {
      Error(Nil) -> 0
      Ok(dist_at_end) -> dist_at_end - dist_at_start - dist(start, end)
    }
  })
  |> list.filter(fn(saving) { saving > 0 })
}

fn positions_at_max_dist(pos: Pos, max_dist) {
  list.range(0, max_dist)
  |> list.fold(set.new(), fn(acc, dist) {
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
  |> set.from_list()
}

fn dist(start: Pos, end: Pos) {
  int.absolute_value(start.row - end.row)
  + int.absolute_value(start.col - end.col)
}

fn find_route(track: Track, pos, acc) {
  case pos == track.end {
    True -> dict.insert(acc, pos, dict.size(acc))
    False -> {
      let assert [next_pos] =
        [
          util.move(pos, util.down),
          util.move(pos, util.up),
          util.move(pos, util.right),
          util.move(pos, util.left),
        ]
        |> list.filter(fn(pos) { !dict.has_key(acc, pos) })
        |> list.filter(fn(pos) { !set.contains(track.walls, pos) })

      find_route(track, next_pos, dict.insert(acc, pos, dict.size(acc)))
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
    from: Track(walls: set.new(), start: Pos(-1, -1), end: Pos(-1, -1)),
    with: fn(track, cells, row) {
      cells
      |> string.to_graphemes
      |> list.index_fold(from: track, with: fn(track, cell, col) {
        case cell {
          "#" -> Track(..track, walls: set.insert(track.walls, Pos(row:, col:)))
          "S" -> Track(..track, start: Pos(row:, col:))
          "E" -> Track(..track, end: Pos(row:, col:))
          "." -> track
          _ -> panic
        }
      })
    },
  )
}
