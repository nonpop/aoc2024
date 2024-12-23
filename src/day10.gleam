import gleam/io
import gleam/list
import gleamy/set
import util.{type Pos, Pos}

pub fn solve1(lines: List(String)) -> Int {
  let #(m, rows, cols) = parse_input(lines)
  sum_scores(m, rows, cols, Pos(0, 0), 0)
}

pub fn solve2(lines: List(String)) -> Int {
  todo
}

fn parse_input(lines) {
  let #(m, rows, cols) = util.parse_table(lines)

  #(util.map_table(m, util.must_string_to_int), rows, cols)
}

fn sum_scores(m, rows, cols, pos, acc) {
  case util.table_get(m, pos) {
    util.TableGetRowOutOfRange -> acc
    util.TableGetColOutOfRange ->
      sum_scores(m, rows, cols, Pos(pos.row + 1, 0), acc)
    util.TableGetOk(_) -> {
      let score =
        peaks_from(
          m,
          rows,
          cols,
          pos,
          0,
          set.new(util.compare_pos),
          set.new(util.compare_pos),
        )
        |> set.count

      sum_scores(m, rows, cols, Pos(pos.row, pos.col + 1), acc + score)
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
        util.TableGetOk(_) if expected_pos_height == 9 -> set.insert(acc, pos)
        util.TableGetOk(_) ->
          [
            Pos(row: pos.row - 1, col: pos.col),
            Pos(row: pos.row + 1, col: pos.col),
            Pos(row: pos.row, col: pos.col - 1),
            Pos(row: pos.row, col: pos.col + 1),
          ]
          |> list.map(fn(new_pos) {
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
          |> list.fold(from: set.new(util.compare_pos), with: set.union)
      }
    }
  }
}
