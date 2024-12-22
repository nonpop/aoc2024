import gleam/int

pub fn must_string_to_int(s: String) -> Int {
  let assert Ok(i) = int.parse(s)
  i
}
