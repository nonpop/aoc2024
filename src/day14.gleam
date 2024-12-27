import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleamy/set
import util.{type Pos, Pos}

pub fn solve1(lines: List(String)) -> Int {
  let #(w, h) = #(101, 103)

  lines
  |> list.filter(fn(line) { line != "" })
  |> list.map(parse_line)
  |> list.map(steps(_, w, h, 100))
  |> safety_factor(w, h)
}

pub fn solve2(lines: List(String)) -> Int {
  let #(w, h) = #(101, 103)

  lines
  |> list.filter(fn(line) { line != "" })
  |> list.map(parse_line)
  |> print_potential_trees(w, h, 0, 10_000)

  -1
}

fn print_potential_trees(robots, w, h, step, max_steps) {
  case step > max_steps {
    True -> Nil
    False -> {
      let robots_set = robots_to_set(robots, set.new(util.compare_pos))
      case step % 1000 == 0 {
        True -> {
          io.println(
            "(step "
            <> int.to_string(step)
            <> "/"
            <> int.to_string(max_steps)
            <> "...)",
          )
        }
        False -> Nil
      }
      case is_potential_tree(robots_set, w, h, Pos(0, 0), 10, 0) {
        True -> {
          io.println("after " <> int.to_string(step) <> " steps:")
          print_step(robots_set, w, h, 0, 0)
        }
        False -> Nil
      }
      print_potential_trees(
        list.map(robots, steps(_, w, h, 1)),
        w,
        h,
        step + 1,
        max_steps,
      )
    }
  }
}

fn is_potential_tree(robots, w, h, pos: Pos, threshold, found) {
  case found >= threshold {
    True -> True
    False ->
      case pos.row >= h {
        True -> False
        False ->
          case pos.col >= w {
            True ->
              is_potential_tree(
                robots,
                w,
                h,
                Pos(row: pos.row + 1, col: 0),
                threshold,
                0,
              )
            False ->
              case set.contains(robots, pos) {
                False ->
                  is_potential_tree(
                    robots,
                    w,
                    h,
                    Pos(..pos, col: pos.col + 1),
                    threshold,
                    0,
                  )
                True ->
                  is_potential_tree(
                    robots,
                    w,
                    h,
                    Pos(..pos, col: pos.col + 1),
                    threshold,
                    found + 1,
                  )
              }
          }
      }
  }
}

fn robots_to_set(robots, acc) {
  case robots {
    [] -> acc
    [#(px, py, _, _), ..xs] ->
      robots_to_set(xs, set.insert(acc, Pos(row: py, col: px)))
  }
}

fn print_step(robots, w, h, row, col) {
  case row >= h {
    True -> io.println("")
    False ->
      case col >= w {
        True -> {
          io.println("")
          print_step(robots, w, h, row + 1, 0)
        }
        False -> {
          case set.contains(robots, Pos(row:, col:)) {
            True -> io.print("#")
            False -> io.print(".")
          }
          print_step(robots, w, h, row, col + 1)
        }
      }
  }
}

fn safety_factor(robots, w, h) {
  let q1 =
    list.filter(robots, fn(robot) {
      let #(px, py, _, _) = robot
      px > w / 2 && py < h / 2
    })
  let q2 =
    list.filter(robots, fn(robot) {
      let #(px, py, _, _) = robot
      px < w / 2 && py < h / 2
    })
  let q3 =
    list.filter(robots, fn(robot) {
      let #(px, py, _, _) = robot
      px < w / 2 && py > h / 2
    })
  let q4 =
    list.filter(robots, fn(robot) {
      let #(px, py, _, _) = robot
      px > w / 2 && py > h / 2
    })

  list.length(q1) * list.length(q2) * list.length(q3) * list.length(q4)
}

fn steps(robot, w, h, count) {
  case count <= 0 {
    True -> robot
    False -> {
      let #(px, py, vx, vy) = robot
      steps(
        #(pos_mod(px + vx, w), pos_mod(py + vy, h), vx, vy),
        w,
        h,
        count - 1,
      )
    }
  }
}

fn pos_mod(x, y) {
  case x < 0 {
    True -> pos_mod(x + y, y)
    False -> x % y
  }
}

fn parse_line(line) {
  let assert Ok(re) =
    regexp.from_string("^p=(\\d+),(\\d+) v=(-?\\d+),(-?\\d+)$")
  let assert [
    regexp.Match(
      submatches: [Some(px), Some(py), Some(vx), Some(vy)],
      ..,
    ),
  ] = regexp.scan(re, line)
  #(
    util.must_string_to_int(px),
    util.must_string_to_int(py),
    util.must_string_to_int(vx),
    util.must_string_to_int(vy),
  )
}
