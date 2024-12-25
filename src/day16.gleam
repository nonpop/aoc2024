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
        #(maze.start, Right, 0),
        #(maze.start, Up, 1000),
        #(maze.start, Down, 1000),
        #(maze.start, Left, 2000),
      ],
      cheapest: map.new(compare_pos_dir)
        |> map.insert(#(maze.start, Right), 0)
        |> map.insert(#(maze.start, Up), 1000)
        |> map.insert(#(maze.start, Down), 1000)
        |> map.insert(#(maze.start, Left), 2000),
    ),
  )
}

pub fn solve2(lines: List(String)) -> Int {
  todo
}

fn find_cheapest(maze: Maze, state: State) {
  case state.worklist {
    [] -> find_cheapest_at(maze.end, state.cheapest)
    [#(pos, dir, cost), ..xs] -> {
      let nexts =
        [
          #(move(pos, dir), dir, cost + 1),
          #(move(pos, turn_left(dir)), turn_left(dir), cost + 1000 + 1),
          #(move(pos, turn_right(dir)), turn_right(dir), cost + 1000 + 1),
        ]
        |> list.filter(fn(p) {
          case set.contains(maze.walls, p.0) {
            True -> False
            False ->
              case map.get(state.cheapest, #(p.0, p.1)) {
                Error(_) -> True
                Ok(cost) -> cost > p.2
              }
          }
        })

      let worklist = list.append(xs, nexts)
      let cheapest =
        nexts
        |> list.fold(from: state.cheapest, with: fn(acc, p) {
          map.insert(acc, #(p.0, p.1), p.2)
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
    [Ok(x), Ok(y), ..xs] -> min([Ok(int.min(x, y)), ..xs])
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
  State(worklist: List(#(Pos, Dir, Int)), cheapest: Map(#(Pos, Dir), Int))
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
