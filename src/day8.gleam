import gleam/dict
import gleam/int
import gleam/list
import gleam/pair
import util.{type Pos, Pos}

pub fn main() {
  util.run(solve1, solve2)
}

fn solve1(lines) {
  let #(m, rows, cols) = util.parse_table(lines)
  solve(m, rows, cols, [1])
}

fn solve2(lines) {
  let #(m, rows, cols) = util.parse_table(lines)
  solve(m, rows, cols, list.range(0, int.max(rows, cols)))
}

fn solve(m, rows, cols, coeffs) {
  let antenna_positions =
    find_antennas(m, dict.new(), Pos(0, 0))
    |> dict.to_list
    |> list.map(pair.second)

  antenna_positions
  |> list.flat_map(freq_antinodes(_, coeffs))
  |> list.filter(in_bounds(_, rows, cols))
  |> list.unique
  |> list.length
  |> util.print_int
}

fn find_antennas(m, acc, pos) {
  case util.table_get(m, pos) {
    util.TableGetRowOutOfRange -> acc
    util.TableGetColOutOfRange -> find_antennas(m, acc, util.next_row(pos))
    util.TableGetOk(".") -> find_antennas(m, acc, util.next_col(pos))
    util.TableGetOk(freq) ->
      find_antennas(m, add_antenna(acc, freq, pos), util.next_col(pos))
  }
}

fn add_antenna(antennas, freq, pos) {
  case dict.get(antennas, freq) {
    Error(Nil) -> dict.insert(antennas, freq, [pos])
    Ok(positions) -> dict.insert(antennas, freq, [pos, ..positions])
  }
}

fn antinodes(pos1: Pos, pos2: Pos, coeffs) {
  let row_diff = pos2.row - pos1.row
  let col_diff = pos2.col - pos1.col

  coeffs
  |> list.flat_map(fn(c) {
    [
      Pos(row: pos2.row + c * row_diff, col: pos2.col + c * col_diff),
      Pos(row: pos1.row - c * row_diff, col: pos1.col - c * col_diff),
    ]
  })
}

fn freq_antinodes(positions, coeffs) {
  positions
  |> list.combination_pairs
  |> list.flat_map(fn(p) { antinodes(p.0, p.1, coeffs) })
}

fn in_bounds(pos: Pos, rows, cols) {
  pos.row >= 0 && pos.col >= 0 && pos.row < rows && pos.col < cols
}
