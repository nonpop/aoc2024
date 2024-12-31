import util.{Pos}

pub fn main() {
  util.run(solve1, solve2)
}

fn solve1(lines) {
  let #(matrix, _, _) = util.parse_table(lines)

  count_xmas(matrix, 0, Pos(0, 0))
  |> util.print_int
}

fn solve2(lines) {
  let #(matrix, _, _) = util.parse_table(lines)

  count_x_mas(matrix, 0, Pos(0, 0))
  |> util.print_int
}

fn count_xmas(matrix, acc, pos) {
  case util.table_get(matrix, pos) {
    util.TableGetRowOutOfRange -> acc
    util.TableGetColOutOfRange -> count_xmas(matrix, acc, util.next_row(pos))
    util.TableGetOk("X") ->
      count_xmas(matrix, acc + count_xmas_from(matrix, pos), util.next_col(pos))
    util.TableGetOk(_) -> count_xmas(matrix, acc, util.next_col(pos))
  }
}

fn count_xmas_from(matrix, pos) {
  count_xmas_from_dir(matrix, pos, util.right)
  + count_xmas_from_dir(matrix, pos, util.down_right)
  + count_xmas_from_dir(matrix, pos, util.down)
  + count_xmas_from_dir(matrix, pos, util.down_left)
  + count_xmas_from_dir(matrix, pos, util.left)
  + count_xmas_from_dir(matrix, pos, util.up_left)
  + count_xmas_from_dir(matrix, pos, util.up)
  + count_xmas_from_dir(matrix, pos, util.up_right)
}

fn count_xmas_from_dir(matrix, pos, dir) {
  let p1 = util.move(pos, dir)
  let p2 = util.move(p1, dir)
  let p3 = util.move(p2, dir)

  let has_xmas =
    has_char_at(matrix, p1, "M")
    && has_char_at(matrix, p2, "A")
    && has_char_at(matrix, p3, "S")

  case has_xmas {
    True -> 1
    False -> 0
  }
}

fn has_char_at(matrix, pos, char) {
  case util.table_get(matrix, pos) {
    util.TableGetRowOutOfRange | util.TableGetColOutOfRange -> False
    util.TableGetOk(c) -> c == char
  }
}

fn count_x_mas(matrix, acc, pos) {
  case util.table_get(matrix, pos) {
    util.TableGetRowOutOfRange -> acc
    util.TableGetColOutOfRange -> count_x_mas(matrix, acc, util.next_row(pos))
    util.TableGetOk("A") ->
      count_x_mas(matrix, acc + count_x_mas_at(matrix, pos), util.next_col(pos))
    util.TableGetOk(_) -> count_x_mas(matrix, acc, util.next_col(pos))
  }
}

fn count_x_mas_at(matrix, pos) {
  let has_diag1 =
    {
      has_char_at(matrix, util.move(pos, util.up_left), "M")
      && has_char_at(matrix, util.move(pos, util.down_right), "S")
    }
    || {
      has_char_at(matrix, util.move(pos, util.up_left), "S")
      && has_char_at(matrix, util.move(pos, util.down_right), "M")
    }

  let has_diag2 =
    {
      has_char_at(matrix, util.move(pos, util.up_right), "M")
      && has_char_at(matrix, util.move(pos, util.down_left), "S")
    }
    || {
      has_char_at(matrix, util.move(pos, util.up_right), "S")
      && has_char_at(matrix, util.move(pos, util.down_left), "M")
    }

  case has_diag1 && has_diag2 {
    True -> 1
    False -> 0
  }
}
