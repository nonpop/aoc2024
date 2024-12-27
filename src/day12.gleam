import gleam/int
import gleam/list
import gleamy/set
import util.{type Pos, Pos}

pub fn solve1(lines: List(String)) -> Int {
  let #(m, _, _) = util.parse_table(lines)
  let areas = find_areas(m, set.new(util.compare_pos), Pos(0, 0), [])

  list.zip(list.map(areas, calc_area), list.map(areas, calc_perim(m, _)))
  |> list.map(fn(p) { p.0 * p.1 })
  |> int.sum
}

pub fn solve2(lines: List(String)) -> Int {
  let #(m, rows, cols) = util.parse_table(lines)
  let areas = find_areas(m, set.new(util.compare_pos), Pos(0, 0), [])

  list.zip(
    list.map(areas, calc_area),
    list.map(areas, calc_discounted_perim(m, rows, cols, _)),
  )
  |> list.map(fn(p) { p.0 * p.1 })
  |> int.sum
}

fn find_areas(m, seen, pos: Pos, acc) {
  case set.contains(seen, pos) {
    True -> find_areas(m, seen, Pos(row: pos.row, col: pos.col + 1), acc)
    False ->
      case util.table_get(m, pos) {
        util.TableGetRowOutOfRange -> acc
        util.TableGetColOutOfRange ->
          find_areas(m, seen, Pos(row: pos.row + 1, col: 0), acc)
        util.TableGetOk(x) -> {
          let area = find_area(m, pos, x, set.new(util.compare_pos))
          let seen = set.union(seen, area)
          find_areas(m, seen, Pos(row: pos.row, col: pos.col + 1), [area, ..acc])
        }
      }
  }
}

fn find_area(m, pos, x, acc) {
  case set.contains(acc, pos) {
    True -> acc
    False -> {
      case util.table_get(m, pos) {
        util.TableGetRowOutOfRange | util.TableGetColOutOfRange -> acc
        util.TableGetOk(y) if x != y -> acc
        util.TableGetOk(_) -> {
          let acc = set.insert(acc, pos)

          neighbors(pos)
          |> list.fold(from: acc, with: fn(acc, pos) {
            find_area(m, pos, x, acc)
          })
        }
      }
    }
  }
}

fn calc_area(area) {
  set.count(area)
}

fn calc_perim(m, area) {
  let assert Ok(pos) = list.first(set.to_list(area))
  let assert util.TableGetOk(x) = util.table_get(m, pos)

  area
  |> set.to_list
  |> list.flat_map(sides_at(m, _, x))
  |> list.length
}

fn calc_discounted_perim(m, rows, cols, area) {
  let assert Ok(pos) = list.first(set.to_list(area))
  let assert util.TableGetOk(x) = util.table_get(m, pos)

  let params = #(m, rows, cols, area, x)

  let tops = count_h_edges(params, Top, Pos(0, 0), False, 0)
  let bottoms = count_h_edges(params, Bottom, Pos(0, 0), False, 0)
  let lefts = count_v_edges(params, Left, Pos(0, 0), False, 0)
  let rights = count_v_edges(params, Right, Pos(0, 0), False, 0)

  tops + bottoms + lefts + rights
}

fn count_h_edges(params, side, pos: Pos, prev, acc) {
  let #(m, rows, cols, area, x) = params

  case pos.row >= rows {
    True -> acc
    False ->
      case pos.col >= cols {
        True ->
          count_h_edges(params, side, Pos(row: pos.row + 1, col: 0), False, acc)
        False -> {
          let next_pos = Pos(..pos, col: pos.col + 1)
          case set.contains(area, pos) {
            False -> count_h_edges(params, side, next_pos, False, acc)
            True ->
              case list.contains(sides_at(m, pos, x), side) {
                False -> count_h_edges(params, side, next_pos, False, acc)
                True ->
                  case prev {
                    True -> count_h_edges(params, side, next_pos, True, acc)
                    False ->
                      count_h_edges(params, side, next_pos, True, acc + 1)
                  }
              }
          }
        }
      }
  }
}

fn count_v_edges(params, side, pos: Pos, prev, acc) {
  let #(m, rows, cols, area, x) = params

  case pos.col >= cols {
    True -> acc
    False ->
      case pos.row >= rows {
        True ->
          count_v_edges(params, side, Pos(row: 0, col: pos.col + 1), False, acc)
        False -> {
          let next_pos = Pos(..pos, row: pos.row + 1)
          case set.contains(area, pos) {
            False -> count_v_edges(params, side, next_pos, False, acc)
            True ->
              case list.contains(sides_at(m, pos, x), side) {
                False -> count_v_edges(params, side, next_pos, False, acc)
                True ->
                  case prev {
                    True -> count_v_edges(params, side, next_pos, True, acc)
                    False ->
                      count_v_edges(params, side, next_pos, True, acc + 1)
                  }
              }
          }
        }
      }
  }
}

fn neighbors(pos: Pos) {
  let left = Pos(row: pos.row, col: pos.col - 1)
  let right = Pos(row: pos.row, col: pos.col + 1)
  let up = Pos(row: pos.row - 1, col: pos.col)
  let down = Pos(row: pos.row + 1, col: pos.col)

  [left, right, up, down]
}

type Side {
  Left
  Right
  Top
  Bottom
}

fn sides_at(m, pos: Pos, x) {
  [
    #(Left, Pos(row: pos.row, col: pos.col - 1)),
    #(Right, Pos(row: pos.row, col: pos.col + 1)),
    #(Top, Pos(row: pos.row - 1, col: pos.col)),
    #(Bottom, Pos(row: pos.row + 1, col: pos.col)),
  ]
  |> list.filter(fn(p) { different_type(m, p.1, x) })
  |> list.map(fn(p) { p.0 })
}

fn different_type(m, pos: Pos, x) {
  case util.table_get(m, pos) {
    util.TableGetOk(y) if x == y -> False
    util.TableGetOk(_) -> True
    util.TableGetRowOutOfRange | util.TableGetColOutOfRange -> True
  }
}
