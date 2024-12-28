import gleam/int
import gleam/list
import gleam/string
import gleamy/map.{type Map}
import ref

pub fn solve1(lines: List(String)) -> Int {
  let #(towels, designs) = parse(lines)

  designs
  |> list.filter(fn(design) {
    possible_arrangements(ref.cell(map.new(string.compare)), towels, design) > 0
  })
  |> list.length
}

pub fn solve2(lines: List(String)) -> Int {
  let #(towels, designs) = parse(lines)

  designs
  |> list.map(fn(design) {
    possible_arrangements(ref.cell(map.new(string.compare)), towels, design)
  })
  |> int.sum
}

fn possible_arrangements(cache, towels, design) {
  let design_str = string.join(design, with: "")
  case map.get(ref.get(cache), design_str) {
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
        ref.set(cache, map.insert(_, design_str, result))
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
  Trie(contains_this: Bool, children: Map(String, Trie))
}

fn trie_new() {
  Trie(contains_this: False, children: map.new(string.compare))
}

fn trie_from_list(words) {
  words
  |> list.map(string.to_graphemes)
  |> list.fold(from: trie_new(), with: fn(trie, word) {
    trie_insert(trie, word)
  })
}

fn trie_insert(trie: Trie, word) {
  case word {
    [] -> Trie(..trie, contains_this: True)
    [c, ..cs] -> {
      let node = case map.get(trie.children, c) {
        Error(Nil) ->
          Trie(contains_this: False, children: map.new(string.compare))
        Ok(node) -> node
      }
      Trie(
        ..trie,
        children: map.insert(trie.children, c, trie_insert(node, cs)),
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
      let for_rest = case map.get(trie.children, c) {
        Error(Nil) -> []
        Ok(node) -> trie_split_prefixes(node, list.append(prefix, [c]), cs)
      }
      list.append(for_this, for_rest)
    }
  }
}
