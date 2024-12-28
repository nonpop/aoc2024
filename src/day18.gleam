import gleam/io
import gleam/list
import gleam/string
import gleamy/set
import util.{Pos}

pub fn solve1(lines: List(String)) -> Int {
  let size = 70
  let amount = 1024

  parse(lines)
  |> drop(amount)
  |> find_shortest(size, set.new(util.compare_pos), [#(Pos(0, 0), 0)])
  |> util.assert_ok
}

pub fn solve2(lines: List(String)) -> Int {
  let size = 70

  parse(lines)
  |> find_blocker([], size, [#(Pos(0, 0), 0)])
  |> util.assert_ok
  |> io.debug

  -1
}

fn find_blocker(bytes, dropped, size, worklist) {
  io.debug(list.length(bytes))

  case bytes {
    [] -> Error(Nil)
    [#(x, y), ..xs] -> {
      let bytes = xs
      let dropped = [Pos(row: y, col: x), ..dropped]

      case
        find_shortest(
          set.from_list(dropped, util.compare_pos),
          size,
          set.new(util.compare_pos),
          [#(Pos(0, 0), 0)],
        )
      {
        Ok(_) -> find_blocker(bytes, dropped, size, worklist)
        Error(Nil) -> Ok(#(x, y))
      }
    }
  }
}

fn find_shortest(corrupted, size, seen, worklist) {
  case worklist {
    [] -> Error(Nil)
    [#(pos, len), ..xs] ->
      case pos == Pos(size, size) {
        True -> Ok(len)
        False ->
          case pos.row < 0 || pos.row > size || pos.col < 0 || pos.col > size {
            True -> find_shortest(corrupted, size, seen, xs)
            False ->
              case set.contains(seen, pos) {
                True -> find_shortest(corrupted, size, seen, xs)
                False -> {
                  case set.contains(corrupted, pos) {
                    True -> find_shortest(corrupted, size, seen, xs)
                    False -> {
                      let seen = set.insert(seen, pos)
                      let worklist =
                        list.append(xs, [
                          #(Pos(..pos, row: pos.row + 1), len + 1),
                          #(Pos(..pos, row: pos.row - 1), len + 1),
                          #(Pos(..pos, col: pos.col + 1), len + 1),
                          #(Pos(..pos, col: pos.col - 1), len + 1),
                        ])
                      find_shortest(corrupted, size, seen, worklist)
                    }
                  }
                }
              }
          }
      }
  }
}

fn drop(coords, amount) {
  coords
  |> list.take(amount)
  |> list.map(fn(p: #(Int, Int)) { Pos(row: p.1, col: p.0) })
  |> set.from_list(util.compare_pos)
}

fn parse(lines) {
  lines
  |> list.filter(fn(line) { line != "" })
  |> list.map(string.split(_, on: ","))
  |> list.map(fn(p) {
    let assert [x, y] = p
    #(util.must_string_to_int(x), util.must_string_to_int(y))
  })
}
