import gleam/int
import gleam/list
import gleam/string
import gleamy/map
import util

pub fn solve1(lines: List(String)) -> Int {
  let assert [line, ..] = lines

  let blocks =
    line
    |> string.to_graphemes
    |> list.map(util.must_string_to_int)
    |> to_blocks(True, 0, 0, map.new(int.compare))

  blocks
  |> compactify(0, map.count(blocks) - 1)
  |> map.to_list
  |> list.sort(by: fn(p1, p2) { int.compare(p1.0, p2.0) })
  |> list.map(fn(p) { p.1 })
  |> checksum(0, 0)
}

pub fn solve2(lines: List(String)) -> Int {
  todo
}

type Block {
  Free
  File(Int)
}

fn to_blocks(disk_map, is_file, file_id, idx, acc) {
  case disk_map {
    [] -> acc
    [len, ..lens] ->
      case is_file {
        True ->
          to_blocks(
            lens,
            False,
            file_id + 1,
            idx + len,
            add_item(acc, File(file_id), idx, len),
          )
        False ->
          to_blocks(
            lens,
            True,
            file_id,
            idx + len,
            add_item(acc, Free, idx, len),
          )
      }
  }
}

fn add_item(blocks, item, idx, len) {
  case len <= 0 {
    True -> blocks
    False -> add_item(map.insert(blocks, idx, item), item, idx + 1, len - 1)
  }
}

fn compactify(blocks, left_idx, right_idx) {
  case left_idx >= right_idx {
    True -> blocks
    False ->
      case map.get(blocks, left_idx), map.get(blocks, right_idx) {
        Error(Nil), _ -> panic
        _, Error(Nil) -> panic
        Ok(_), Ok(Free) -> compactify(blocks, left_idx, right_idx - 1)
        Ok(File(_)), Ok(_) -> compactify(blocks, left_idx + 1, right_idx)
        Ok(Free), Ok(File(file_id)) ->
          blocks
          |> map.insert(left_idx, File(file_id))
          |> map.insert(right_idx, Free)
          |> compactify(left_idx + 1, right_idx - 1)
      }
  }
}

fn checksum(blocks, idx, acc) {
  case blocks {
    [] -> acc
    [Free, ..bs] -> checksum(bs, idx + 1, acc)
    [File(file_id), ..bs] -> checksum(bs, idx + 1, acc + idx * file_id)
  }
}
