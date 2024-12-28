import gleam/list
import gleam/string

pub fn solve1(lines: List(String)) -> Int {
  let #(towels, designs) = parse(lines)

  designs
  |> list.filter(possible_design(_, towels, towels))
  |> list.length
}

pub fn solve2(lines: List(String)) -> Int {
  todo
}

fn possible_design(design, towels, all_towels) {
  case towels {
    [] -> design == ""
    [x, ..xs] ->
      case string.starts_with(design, x) {
        False -> possible_design(design, xs, all_towels)
        True ->
          possible_design(
            string.drop_start(design, string.length(x)),
            all_towels,
            all_towels,
          )
          || possible_design(design, xs, all_towels)
      }
  }
}

fn parse(lines) {
  let assert [towels_str, "", ..designs] = lines

  let towels = string.split(towels_str, on: ", ")
  #(towels, designs)
}
