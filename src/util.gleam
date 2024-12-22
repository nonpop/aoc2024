import gleam/int
import glearray

pub fn assert_ok(result) {
  let assert Ok(value) = result
  value
}

pub fn must_string_to_int(s: String) -> Int {
  s |> int.parse |> assert_ok
}

pub type TableGetResult(t) {
  TableGetOk(t)
  TableGetRowOutOfRange
  TableGetColOutOfRange
}

pub fn table_get(table, pos) {
  let #(row_idx, col_idx) = pos

  case glearray.get(table, row_idx) {
    Error(Nil) -> TableGetRowOutOfRange
    Ok(row) ->
      case glearray.get(row, col_idx) {
        Error(Nil) -> TableGetColOutOfRange
        Ok(value) -> TableGetOk(value)
      }
  }
}
