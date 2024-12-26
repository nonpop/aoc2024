import gleam/int
import gleam/list
import gleam/order
import gleam/string
import gleamy/map.{type Map}
import gleamy/set.{type Set}
import util.{type Pos, Pos}

pub fn solve1(lines: List(String)) -> Int {
  let maze = parse(lines)
  find_cheapest(
    maze,
    State(
      worklist: [
        #([], maze.start, Right, 0),
        #([], maze.start, Up, 1000),
        #([], maze.start, Down, 1000),
        #([], maze.start, Left, 2000),
      ],
      cheapest: map.new(compare_pos_dir)
        |> map.insert(#(maze.start, Right), #([[]], 0))
        |> map.insert(#(maze.start, Up), #([[]], 1000))
        |> map.insert(#(maze.start, Down), #([[]], 1000))
        |> map.insert(#(maze.start, Left), #([[]], 2000)),
    ),
  ).1
}

pub fn solve2(lines: List(String)) -> Int {
  // this will run a few minutes (but less than 10min)
  let maze = parse(lines)
  find_cheapest(
    maze,
    State(
      worklist: [
        #([], maze.start, Right, 0),
        #([], maze.start, Up, 1000),
        #([], maze.start, Down, 1000),
        #([], maze.start, Left, 2000),
      ],
      cheapest: map.new(compare_pos_dir)
        |> map.insert(#(maze.start, Right), #([[]], 0))
        |> map.insert(#(maze.start, Up), #([[]], 1000))
        |> map.insert(#(maze.start, Down), #([[]], 1000))
        |> map.insert(#(maze.start, Left), #([[]], 2000)),
    ),
  ).0
  |> list.flatten
  |> set.from_list(util.compare_pos)
  |> fn(positions_in_prefixes) { set.count(positions_in_prefixes) + 1 }
}

fn find_cheapest(maze: Maze, state: State) {
  case state.worklist {
    [] -> find_cheapest_at(maze.end, state.cheapest)
    [#(prefix, pos, dir, cost), ..xs] -> {
      let prefix = [pos, ..prefix]
      let nexts =
        [
          #(prefix, move(pos, dir), dir, cost + 1),
          #(prefix, move(pos, turn_left(dir)), turn_left(dir), cost + 1000 + 1),
          #(
            prefix,
            move(pos, turn_right(dir)),
            turn_right(dir),
            cost + 1000 + 1,
          ),
        ]
        |> list.filter(fn(p) { !set.contains(maze.walls, p.1) })
        |> list.filter(fn(p) {
          case map.get(state.cheapest, #(p.1, p.2)) {
            Error(_) -> True
            Ok(#(_, cost)) -> p.3 <= cost
          }
        })

      let worklist = list.append(nexts, xs)
      let cheapest =
        nexts
        |> list.fold(from: state.cheapest, with: fn(acc, p) {
          let key = #(p.1, p.2)
          case map.get(acc, key) {
            Error(Nil) -> map.insert(acc, key, #([p.0], p.3))
            Ok(#(prefixes, cost)) ->
              case p.3 < cost {
                True -> map.insert(acc, key, #([p.0], p.3))
                False -> map.insert(acc, key, #([p.0, ..prefixes], p.3))
              }
          }
        })

      find_cheapest(maze, State(worklist:, cheapest:))
    }
  }
}

fn find_cheapest_at(pos, cheapest) {
  let up = map.get(cheapest, #(pos, Up))
  let down = map.get(cheapest, #(pos, Down))
  let left = map.get(cheapest, #(pos, Left))
  let right = map.get(cheapest, #(pos, Right))

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

type Dir {
  Up
  Down
  Left
  Right
}

fn move(pos: Pos, dir) {
  case dir {
    Up -> Pos(..pos, row: pos.row - 1)
    Down -> Pos(..pos, row: pos.row + 1)
    Left -> Pos(..pos, col: pos.col - 1)
    Right -> Pos(..pos, col: pos.col + 1)
  }
}

fn turn_left(dir) {
  case dir {
    Up -> Left
    Down -> Right
    Left -> Down
    Right -> Up
  }
}

fn turn_right(dir) {
  case dir {
    Up -> Right
    Down -> Left
    Left -> Up
    Right -> Down
  }
}

fn dir_to_int(dir) {
  case dir {
    Up -> 0
    Down -> 1
    Left -> 2
    Right -> 3
  }
}

fn compare_pos_dir(pd1: #(Pos, Dir), pd2: #(Pos, Dir)) {
  order.break_tie(
    util.compare_pos(pd1.0, pd2.0),
    int.compare(dir_to_int(pd1.1), dir_to_int(pd2.1)),
  )
}

type State {
  State(
    worklist: List(#(List(Pos), Pos, Dir, Int)),
    cheapest: Map(#(Pos, Dir), #(List(List(Pos)), Int)),
  )
}

fn parse(lines) {
  lines
  |> list.filter(fn(line) { line != "" })
  |> list.index_fold(
    from: Maze(Pos(-1, -1), Pos(-1, -1), set.new(util.compare_pos)),
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
    "#" -> Maze(..m, walls: set.insert(m.walls, Pos(row, col)))
    "S" -> Maze(..m, start: Pos(row, col))
    "E" -> Maze(..m, end: Pos(row, col))
    "." -> m
    _ -> panic
  }
}
