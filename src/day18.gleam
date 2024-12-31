import gleam/int
import gleam/io
import gleam/list
import gleam/set
import gleam/string
import util.{Pos}

pub fn main() {
  util.run(solve1, solve2)
}

fn solve1(lines) {
  let size = 70
  let amount = 1024

  parse(lines)
  |> drop(amount)
  |> find_shortest(size, set.new(), [#(Pos(0, 0), 0)])
  |> util.assert_ok
  |> util.print_int
}

fn solve2(lines) {
  // slow but <1min

  let size = 70

  parse(lines)
  |> find_blocker([], size, [#(Pos(0, 0), 0)])
  |> util.assert_ok
  |> fn(p) { io.println(int.to_string(p.0) <> "," <> int.to_string(p.1)) }
}

fn find_blocker(bytes, dropped, size, worklist) {
  case list.length(bytes) % 100 == 0 {
    True -> io.println(int.to_string(list.length(bytes)))
    False -> Nil
  }

  case bytes {
    [] -> Error(Nil)
    [#(x, y), ..xs] -> {
      let bytes = xs
      let dropped = [Pos(row: y, col: x), ..dropped]

      case
        find_shortest(set.from_list(dropped), size, set.new(), [#(Pos(0, 0), 0)])
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
                          #(util.move(pos, util.down), len + 1),
                          #(util.move(pos, util.up), len + 1),
                          #(util.move(pos, util.right), len + 1),
                          #(util.move(pos, util.left), len + 1),
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
  |> set.from_list()
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
