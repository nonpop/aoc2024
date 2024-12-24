import gleam/int
import gleam/list
import gleamy/set
import util.{type Pos, Pos}

pub fn solve1(lines: List(String)) -> Int {
  let #(m, _, _) = util.parse_table(lines)
  calc_price(m, set.new(util.compare_pos), Pos(0, 0), 0)
}

pub fn solve2(lines: List(String)) -> Int {
  todo
}

fn calc_price(m, seen, pos, acc) {
  case util.table_get(m, pos) {
    util.TableGetRowOutOfRange -> acc
    util.TableGetColOutOfRange ->
      calc_price(m, seen, Pos(row: pos.row + 1, col: 0), acc)
    util.TableGetOk(x) -> {
      let #(seen, area, perim) = calc_area_and_perim(m, seen, pos, x, 0, 0)
      let price = area * perim
      calc_price(m, seen, Pos(row: pos.row, col: pos.col + 1), acc + price)
    }
  }
}

fn calc_area_and_perim(m, seen, pos, x, area_acc, perim_acc) {
  case set.contains(seen, pos) {
    True -> #(seen, area_acc, perim_acc)
    False -> {
      case util.table_get(m, pos) {
        util.TableGetRowOutOfRange | util.TableGetColOutOfRange -> #(
          seen,
          area_acc,
          perim_acc,
        )
        util.TableGetOk(y) if x != y -> #(seen, area_acc, perim_acc)
        util.TableGetOk(_) -> {
          let seen = set.insert(seen, pos)
          let area_here = 1
          let perim_here = sides_at(m, pos, x)

          neighbors(pos)
          |> list.fold(
            from: #(seen, area_acc + area_here, perim_acc + perim_here),
            with: fn(acc, pos) {
              calc_area_and_perim(m, acc.0, pos, x, acc.1, acc.2)
            },
          )
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

fn sides_at(m, pos: Pos, x) {
  neighbors(pos)
  |> list.map(different_type(m, _, x))
  |> int.sum
}

fn different_type(m, pos: Pos, x) {
  case util.table_get(m, pos) {
    util.TableGetOk(y) if x == y -> 0
    util.TableGetOk(_) -> 1
    util.TableGetRowOutOfRange | util.TableGetColOutOfRange -> 1
  }
}
