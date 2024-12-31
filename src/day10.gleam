import gleam/list
import gleam/set
import util.{type Pos, Pos}

pub fn main() {
  util.run(solve1, solve2)
}

fn solve1(lines) {
  let #(m, rows, cols) = parse(lines)

  sum_scores(m, rows, cols, Pos(0, 0), 0)
  |> util.print_int
}

fn solve2(lines) {
  let #(m, rows, cols) = parse(lines)

  sum_ratings(m, rows, cols, Pos(0, 0), 0)
  |> util.print_int
}

fn parse(lines) {
  let #(m, rows, cols) = util.parse_table(lines)

  #(util.map_table(m, util.must_string_to_int), rows, cols)
}

fn sum_scores(m, rows, cols, pos, acc) {
  case util.table_get(m, pos) {
    util.TableGetRowOutOfRange -> acc
    util.TableGetColOutOfRange ->
      sum_scores(m, rows, cols, util.next_row(pos), acc)
    util.TableGetOk(_) -> {
      let score =
        peaks_from(m, rows, cols, pos, 0, set.new(), [])
        |> set.from_list()
        |> set.size

      sum_scores(m, rows, cols, util.next_col(pos), acc + score)
    }
  }
}

fn sum_ratings(m, rows, cols, pos, acc) {
  case util.table_get(m, pos) {
    util.TableGetRowOutOfRange -> acc
    util.TableGetColOutOfRange ->
      sum_ratings(m, rows, cols, Pos(pos.row + 1, 0), acc)
    util.TableGetOk(_) -> {
      let score =
        peaks_from(m, rows, cols, pos, 0, set.new(), [])
        |> list.length

      sum_ratings(m, rows, cols, util.next_col(pos), acc + score)
    }
  }
}

fn peaks_from(m, rows, cols, pos, expected_pos_height, seen, acc) {
  case set.contains(seen, pos) {
    True -> acc
    False -> {
      let seen = set.insert(seen, pos)
      case util.table_get(m, pos) {
        util.TableGetRowOutOfRange | util.TableGetColOutOfRange -> acc
        util.TableGetOk(pos_height) if pos_height != expected_pos_height -> acc
        util.TableGetOk(_) if expected_pos_height == 9 -> [pos, ..acc]
        util.TableGetOk(_) ->
          [
            util.move(pos, util.up),
            util.move(pos, util.down),
            util.move(pos, util.left),
            util.move(pos, util.right),
          ]
          |> list.flat_map(fn(new_pos) {
            peaks_from(
              m,
              rows,
              cols,
              new_pos,
              expected_pos_height + 1,
              seen,
              acc,
            )
          })
      }
    }
  }
}
