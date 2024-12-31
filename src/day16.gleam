import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/order
import gleam/pair
import gleam/set.{type Set}
import gleam/string
import util.{type Dir, type Pos, Pos}

pub fn main() {
  util.run(solve1, solve2)
}

fn solve1(lines) {
  // slow but <1min

  let maze = parse(lines)
  find_cheapest(
    maze,
    State(
      worklist: [
        #([], maze.start, util.right, 0),
        #([], maze.start, util.up, 1000),
        #([], maze.start, util.down, 1000),
        #([], maze.start, util.left, 2000),
      ],
      cheapest: dict.new()
        |> dict.insert(#(maze.start, util.right), #([[]], 0))
        |> dict.insert(#(maze.start, util.up), #([[]], 1000))
        |> dict.insert(#(maze.start, util.down), #([[]], 1000))
        |> dict.insert(#(maze.start, util.left), #([[]], 2000)),
    ),
  )
  |> pair.second
  |> util.print_int
}

fn solve2(lines) {
  // slow but <1min

  let maze = parse(lines)
  find_cheapest(
    maze,
    State(
      worklist: [
        #([], maze.start, util.right, 0),
        #([], maze.start, util.up, 1000),
        #([], maze.start, util.down, 1000),
        #([], maze.start, util.left, 2000),
      ],
      cheapest: dict.new()
        |> dict.insert(#(maze.start, util.right), #([[]], 0))
        |> dict.insert(#(maze.start, util.up), #([[]], 1000))
        |> dict.insert(#(maze.start, util.down), #([[]], 1000))
        |> dict.insert(#(maze.start, util.left), #([[]], 2000)),
    ),
  )
  |> pair.first
  |> list.flatten
  |> set.from_list()
  |> fn(positions_in_prefixes) { set.size(positions_in_prefixes) + 1 }
  |> util.print_int
}

fn find_cheapest(maze: Maze, state: State) {
  case state.worklist {
    [] -> find_cheapest_at(maze.end, state.cheapest)
    [#(prefix, pos, dir, cost), ..xs] -> {
      let prefix = [pos, ..prefix]
      let nexts =
        [
          #(prefix, util.move(pos, dir), dir, cost + 1),
          #(
            prefix,
            util.move(pos, util.turn_left(dir)),
            util.turn_left(dir),
            cost + 1000 + 1,
          ),
          #(
            prefix,
            util.move(pos, util.turn_right(dir)),
            util.turn_right(dir),
            cost + 1000 + 1,
          ),
        ]
        |> list.filter(fn(p) { !set.contains(maze.walls, p.1) })
        |> list.filter(fn(p) {
          case dict.get(state.cheapest, #(p.1, p.2)) {
            Error(_) -> True
            Ok(#(_, cost)) -> p.3 <= cost
          }
        })

      let worklist = list.append(nexts, xs)
      let cheapest =
        nexts
        |> list.fold(from: state.cheapest, with: fn(acc, p) {
          let key = #(p.1, p.2)
          case dict.get(acc, key) {
            Error(Nil) -> dict.insert(acc, key, #([p.0], p.3))
            Ok(#(prefixes, cost)) ->
              case p.3 < cost {
                True -> dict.insert(acc, key, #([p.0], p.3))
                False -> dict.insert(acc, key, #([p.0, ..prefixes], p.3))
              }
          }
        })

      find_cheapest(maze, State(worklist:, cheapest:))
    }
  }
}

fn find_cheapest_at(pos, cheapest) {
  let up = dict.get(cheapest, #(pos, util.up))
  let down = dict.get(cheapest, #(pos, util.down))
  let left = dict.get(cheapest, #(pos, util.left))
  let right = dict.get(cheapest, #(pos, util.right))

  min([up, down, left, right])
}

fn min(xs) {
  case xs {
    [] -> panic
    [Error(_), ..xs] -> min(xs)
    [Ok(x)] -> x
    [Ok(x), Error(_), ..xs] -> min([Ok(x), ..xs])
    [Ok(#(ps, x)), Ok(#(qs, y)), ..xs] -> {
      case int.compare(x, y) {
        order.Lt -> min([Ok(#(ps, x)), ..xs])
        order.Eq -> min([Ok(#(list.append(ps, qs), x)), ..xs])
        order.Gt -> min([Ok(#(qs, y)), ..xs])
      }
    }
  }
}

type Maze {
  Maze(start: Pos, end: Pos, walls: Set(Pos))
}

type State {
  State(
    worklist: List(#(List(Pos), Pos, Dir, Int)),
    cheapest: Dict(#(Pos, Dir), #(List(List(Pos)), Int)),
  )
}

fn parse(lines) {
  lines
  |> list.filter(fn(line) { line != "" })
  |> list.index_fold(
    from: Maze(Pos(-1, -1), Pos(-1, -1), set.new()),
    with: parse_line,
  )
}

fn parse_line(m, line, row) {
  line
  |> string.to_graphemes
  |> list.index_fold(from: m, with: fn(m, cell, col) {
    parse_cell(m, cell, row, col)
  })
}

fn parse_cell(m: Maze, cell, row, col) {
  case cell {
    "#" -> Maze(..m, walls: set.insert(m.walls, Pos(row:, col:)))
    "S" -> Maze(..m, start: Pos(row, col))
    "E" -> Maze(..m, end: Pos(row, col))
    "." -> m
    _ -> panic
  }
}
