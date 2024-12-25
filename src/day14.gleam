import gleam/list
import gleam/option.{Some}
import gleam/regexp
import util

pub fn solve1(lines: List(String)) -> Int {
  let #(w, h) = #(101, 103)

  lines
  |> list.filter(fn(line) { line != "" })
  |> list.map(parse_line)
  |> list.map(steps(_, w, h, 100))
  |> safety_factor(w, h)
}

pub fn solve2(lines: List(String)) -> Int {
  todo
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
