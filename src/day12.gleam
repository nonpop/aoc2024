import gleam/int
import gleam/list
import gleam/pair
import gleam/set
import util.{type Pos, Pos}

pub fn main() {
  util.run(solve1, solve2)
}

fn solve1(lines) {
  let #(m, _, _) = util.parse_table(lines)
  let areas = find_areas(m, set.new(), Pos(0, 0), [])

  list.zip(list.map(areas, calc_area), list.map(areas, calc_perim(m, _)))
  |> list.map(fn(p) { p.0 * p.1 })
  |> int.sum
  |> util.print_int
}

fn solve2(lines) {
  let #(m, rows, cols) = util.parse_table(lines)
  let areas = find_areas(m, set.new(), Pos(0, 0), [])

  list.zip(
    list.map(areas, calc_area),
    list.map(areas, calc_discounted_perim(m, rows, cols, _)),
  )
  |> list.map(fn(p) { p.0 * p.1 })
  |> int.sum
  |> util.print_int
}

fn find_areas(m, seen, pos, acc) {
  case set.contains(seen, pos) {
    True -> find_areas(m, seen, util.next_col(pos), acc)
    False ->
      case util.table_get(m, pos) {
        util.TableGetRowOutOfRange -> acc
        util.TableGetColOutOfRange ->
          find_areas(m, seen, util.next_row(pos), acc)
        util.TableGetOk(x) -> {
          let area = find_area(m, pos, x, set.new())
          let seen = set.union(seen, area)
          find_areas(m, seen, util.next_col(pos), [area, ..acc])
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
  set.size(area)
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

fn neighbors(pos) {
  [
    util.move(pos, util.left),
    util.move(pos, util.right),
    util.move(pos, util.up),
    util.move(pos, util.down),
  ]
}

type Side {
  Left
  Right
  Top
  Bottom
}

fn sides_at(m, pos, x) {
  [
    #(Left, util.move(pos, util.left)),
    #(Right, util.move(pos, util.right)),
    #(Top, util.move(pos, util.up)),
    #(Bottom, util.move(pos, util.down)),
  ]
  |> list.filter(fn(p) { different_type(m, p.1, x) })
  |> list.map(pair.first)
}

fn different_type(m, pos, x) {
  case util.table_get(m, pos) {
    util.TableGetOk(y) if x == y -> False
    util.TableGetOk(_) -> True
    util.TableGetRowOutOfRange | util.TableGetColOutOfRange -> True
  }
}
