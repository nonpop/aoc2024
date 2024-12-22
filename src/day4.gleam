import gleam/list
import gleam/string
import glearray

pub fn solve1(lines: List(String)) -> Int {
  parse(lines)
  |> count_xmas(0, 0, 0)
}

pub fn solve2(lines: List(String)) -> Int {
  parse(lines)
  |> count_x_mas(0, 0, 0)
}

fn parse(lines) {
  lines
  |> list.filter(fn(s) { s != "" })
  |> list.map(fn(line) { line |> string.to_graphemes |> glearray.from_list })
  |> glearray.from_list
}

fn count_xmas(matrix, acc, row_idx, col_idx) {
  case glearray.get(matrix, row_idx) {
    Error(Nil) -> acc
    Ok(row) ->
      case glearray.get(row, col_idx) {
        Error(Nil) -> count_xmas(matrix, acc, row_idx + 1, 0)
        Ok("X") ->
          count_xmas(
            matrix,
            acc + count_xmas_from(matrix, row_idx, col_idx),
            row_idx,
            col_idx + 1,
          )
        Ok(_) -> count_xmas(matrix, acc, row_idx, col_idx + 1)
      }
  }
}

fn count_xmas_from(matrix, row_idx, col_idx) {
  count_xmas_from_dir(matrix, row_idx, col_idx, 0, 1)
  + count_xmas_from_dir(matrix, row_idx, col_idx, 1, 1)
  + count_xmas_from_dir(matrix, row_idx, col_idx, 1, 0)
  + count_xmas_from_dir(matrix, row_idx, col_idx, 1, -1)
  + count_xmas_from_dir(matrix, row_idx, col_idx, 0, -1)
  + count_xmas_from_dir(matrix, row_idx, col_idx, -1, -1)
  + count_xmas_from_dir(matrix, row_idx, col_idx, -1, 0)
  + count_xmas_from_dir(matrix, row_idx, col_idx, -1, 1)
}

fn count_xmas_from_dir(matrix, row_idx, col_idx, row_ofs, col_ofs) {
  let has_xmas =
    has_char_at(matrix, row_idx + row_ofs, col_idx + col_ofs, "M")
    && has_char_at(matrix, row_idx + 2 * row_ofs, col_idx + 2 * col_ofs, "A")
    && has_char_at(matrix, row_idx + 3 * row_ofs, col_idx + 3 * col_ofs, "S")
  case has_xmas {
    True -> 1
    False -> 0
  }
}

fn has_char_at(matrix, row_idx, col_idx, char) {
  case glearray.get(matrix, row_idx) {
    Error(Nil) -> False
    Ok(row) ->
      case glearray.get(row, col_idx) {
        Error(Nil) -> False
        Ok(c) -> c == char
      }
  }
}

fn count_x_mas(matrix, acc, row_idx, col_idx) {
  case glearray.get(matrix, row_idx) {
    Error(Nil) -> acc
    Ok(row) ->
      case glearray.get(row, col_idx) {
        Error(Nil) -> count_x_mas(matrix, acc, row_idx + 1, 0)
        Ok("A") ->
          count_x_mas(
            matrix,
            acc + count_x_mas_at(matrix, row_idx, col_idx),
            row_idx,
            col_idx + 1,
          )
        Ok(_) -> count_x_mas(matrix, acc, row_idx, col_idx + 1)
      }
  }
}

fn count_x_mas_at(matrix, row_idx, col_idx) {
  let has_diag1 =
    {
      has_char_at(matrix, row_idx - 1, col_idx - 1, "M")
      && has_char_at(matrix, row_idx + 1, col_idx + 1, "S")
    }
    || {
      has_char_at(matrix, row_idx - 1, col_idx - 1, "S")
      && has_char_at(matrix, row_idx + 1, col_idx + 1, "M")
    }
  let has_diag2 =
    {
      has_char_at(matrix, row_idx - 1, col_idx + 1, "M")
      && has_char_at(matrix, row_idx + 1, col_idx - 1, "S")
    }
    || {
      has_char_at(matrix, row_idx - 1, col_idx + 1, "S")
      && has_char_at(matrix, row_idx + 1, col_idx - 1, "M")
    }
  case has_diag1 && has_diag2 {
    True -> 1
    False -> 0
  }
}
