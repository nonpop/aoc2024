import gleam/int

pub fn assert_ok(result) {
  let assert Ok(value) = result
  value
}

pub fn must_string_to_int(s: String) -> Int {
  s |> int.parse |> assert_ok
}
