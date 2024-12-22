import gleam/list
import gleam/string
import gleamy/map
import util.{type Pos, Pos}

pub fn solve1(lines: List(String)) -> Int {
  let #(m, rows, cols) = util.parse_table(lines)
  let antenna_positions =
    find_antennas(m, map.new(string.compare), Pos(0, 0))
    |> map.to_list
    |> list.map(fn(kv) { kv.1 })

  antenna_positions
  |> list.flat_map(freq_antinodes)
  |> list.filter(in_bounds(_, rows, cols))
  |> list.unique
  |> list.length
}

pub fn solve2(lines: List(String)) -> Int {
  todo
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

fn antinodes(pos1: Pos, pos2: Pos) {
  let row_diff = pos2.row - pos1.row
  let col_diff = pos2.col - pos1.col
  let antinode1 = Pos(row: pos2.row + row_diff, col: pos2.col + col_diff)
  let antinode2 = Pos(row: pos1.row - row_diff, col: pos1.col - col_diff)

  #(antinode1, antinode2)
}

fn pairs(xs) {
  case xs {
    [] -> []
    [x, ..xs] -> xs |> list.map(fn(y) { #(x, y) }) |> list.append(pairs(xs))
  }
}

fn freq_antinodes(positions) {
  positions
  |> pairs
  |> list.flat_map(fn(p) {
    let #(pos1, pos2) = p
    let #(an1, an2) = antinodes(pos1, pos2)
    [an1, an2]
  })
}

fn in_bounds(pos: Pos, rows, cols) {
  pos.row >= 0 && pos.col >= 0 && pos.row < rows && pos.col < cols
}
