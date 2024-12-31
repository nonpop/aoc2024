import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/string
import ref
import util

pub fn main() {
  util.run(solve1, solve2)
}

fn solve1(lines) {
  let #(towels, designs) = parse(lines)

  designs
  |> list.filter(fn(design) {
    possible_arrangements(ref.cell(dict.new()), towels, design) > 0
  })
  |> list.length
  |> util.print_int
}

fn solve2(lines) {
  let #(towels, designs) = parse(lines)

  designs
  |> list.map(fn(design) {
    possible_arrangements(ref.cell(dict.new()), towels, design)
  })
  |> int.sum
  |> util.print_int
}

fn possible_arrangements(cache, towels, design) {
  let design_str = string.join(design, with: "")
  case dict.get(ref.get(cache), design_str) {
    Ok(result) -> result
    Error(Nil) ->
      trie_split_prefixes(towels, [], design)
      |> list.map(fn(p) {
        case p.1 == [] {
          True -> 1
          False -> possible_arrangements(cache, towels, p.1)
        }
      })
      |> int.sum
      |> fn(result) {
        ref.set(cache, dict.insert(_, design_str, result))
        result
      }
  }
}

fn parse(lines) {
  let assert [towels_str, "", ..design_strs] = lines

  let towels =
    string.split(towels_str, on: ", ")
    |> trie_from_list

  let designs = design_strs |> list.map(string.to_graphemes)

  #(towels, designs)
}

type Trie {
  Trie(contains_this: Bool, children: Dict(String, Trie))
}

fn trie_new() {
  Trie(contains_this: False, children: dict.new())
}

fn trie_from_list(words) {
  words
  |> list.map(string.to_graphemes)
  |> list.fold(from: trie_new(), with: trie_insert)
}

fn trie_insert(trie: Trie, word) {
  case word {
    [] -> Trie(..trie, contains_this: True)
    [c, ..cs] -> {
      let node = case dict.get(trie.children, c) {
        Error(Nil) -> Trie(contains_this: False, children: dict.new())
        Ok(node) -> node
      }
      Trie(
        ..trie,
        children: dict.insert(trie.children, c, trie_insert(node, cs)),
      )
    }
  }
}

fn trie_split_prefixes(trie: Trie, prefix, suffix) {
  let for_this = case trie.contains_this {
    True -> [#(prefix, suffix)]
    False -> []
  }
  case suffix {
    [] -> for_this
    [c, ..cs] -> {
      let for_rest = case dict.get(trie.children, c) {
        Error(Nil) -> []
        Ok(node) -> trie_split_prefixes(node, list.append(prefix, [c]), cs)
      }
      list.append(for_this, for_rest)
    }
  }
}
