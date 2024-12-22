import gleam/int
import gleam/list
import gleam/string
import gleamy/map
import util.{type Pos, Pos}

pub fn solve1(lines: List(String)) -> Int {
  let #(m, rows, cols) = util.parse_table(lines)
  solve(m, rows, cols, [1])
}

pub fn solve2(lines: List(String)) -> Int {
  let #(m, rows, cols) = util.parse_table(lines)
  solve(m, rows, cols, list.range(0, int.max(rows, cols)))
}

fn solve(m, rows, cols, coeffs) {
  let antenna_positions =
    find_antennas(m, map.new(string.compare), Pos(0, 0))
    |> map.to_list
    |> list.map(fn(kv) { kv.1 })

  antenna_positions
  |> list.flat_map(freq_antinodes(_, coeffs))
  |> list.filter(in_bounds(_, rows, cols))
  |> list.unique
  |> list.length
}

fn find_antennas(m, acc, pos) {
  case util.table_get(m, pos) {
    util.TableGetRowOutOfRange -> acc
    util.TableGetColOutOfRange ->
      find_antennas(m, acc, Pos(row: pos.row + 1, col: 0))
    util.TableGetOk(".") ->
      find_antennas(m, acc, Pos(row: pos.row, col: pos.col + 1))
    util.TableGetOk(freq) ->
      find_antennas(
        m,
        add_antenna(acc, freq, pos),
        Pos(row: pos.row, col: pos.col + 1),
      )
  }
}

fn add_antenna(antennas, freq, pos) {
  case map.get(antennas, freq) {
    Error(Nil) -> map.insert(antennas, freq, [pos])
    Ok(positions) -> map.insert(antennas, freq, [pos, ..positions])
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

fn pairs(xs) {
  case xs {
    [] -> []
    [x, ..xs] -> xs |> list.map(fn(y) { #(x, y) }) |> list.append(pairs(xs))
  }
}

fn freq_antinodes(positions, coeffs) {
  positions
  |> pairs
  |> list.flat_map(fn(p) { antinodes(p.0, p.1, coeffs) })
}

fn in_bounds(pos: Pos, rows, cols) {
  pos.row >= 0 && pos.col >= 0 && pos.row < rows && pos.col < cols
}
