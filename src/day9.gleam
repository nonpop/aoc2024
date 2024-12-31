import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/string
import util

pub fn main() {
  util.run(solve1, solve2)
}

fn solve1(lines) {
  let assert [line, ..] = lines

  let blocks =
    line
    |> string.to_graphemes
    |> list.map(util.must_string_to_int)
    |> to_blocks(True, 0, 0, dict.new())

  blocks
  |> compactify(0, dict.size(blocks) - 1)
  |> dict.to_list
  |> list.sort(by: fn(p1, p2) { int.compare(p1.0, p2.0) })
  |> list.map(pair.second)
  |> checksum(0, 0)
  |> util.print_int
}

fn solve2(lines) {
  // slow but <2min

  let assert [line, ..] = lines

  let blocks =
    line
    |> string.to_graphemes
    |> list.map(util.must_string_to_int)
    |> to_blocks(True, 0, 0, dict.new())

  let max_file_id =
    blocks
    |> dict.to_list
    |> list.filter_map(fn(b) {
      case b.1 {
        File(id) -> Ok(id)
        Free -> Error(Nil)
      }
    })
    |> list.fold(from: 0, with: int.max)

  blocks
  |> compactify2(max_file_id, dict.size(blocks))
  |> dict.to_list
  |> list.sort(by: fn(p1, p2) { int.compare(p1.0, p2.0) })
  |> list.map(pair.second)
  |> checksum(0, 0)
  |> util.print_int
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
    False -> add_item(dict.insert(blocks, idx, item), item, idx + 1, len - 1)
  }
}

fn compactify(blocks, left_idx, right_idx) {
  case left_idx >= right_idx {
    True -> blocks
    False ->
      case dict.get(blocks, left_idx), dict.get(blocks, right_idx) {
        Error(Nil), _ -> panic
        _, Error(Nil) -> panic
        Ok(_), Ok(Free) -> compactify(blocks, left_idx, right_idx - 1)
        Ok(File(_)), Ok(_) -> compactify(blocks, left_idx + 1, right_idx)
        Ok(Free), Ok(File(file_id)) ->
          blocks
          |> dict.insert(left_idx, File(file_id))
          |> dict.insert(right_idx, Free)
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

fn compactify2(blocks, cur_file_id, end_idx) {
  case cur_file_id < 0 {
    True -> blocks
    False -> {
      case cur_file_id % 100 {
        0 -> io.println(int.to_string(cur_file_id))
        _ -> Nil
      }
      let #(new_blocks, new_end_idx) =
        try_move_file(blocks, cur_file_id, end_idx)
      compactify2(new_blocks, cur_file_id - 1, new_end_idx)
    }
  }
}

fn try_move_file(blocks, file_id, end_idx) {
  let #(file_start_idx, file_len) = find_file(blocks, file_id, end_idx - 1)

  case find_free(blocks, file_len, 0, file_start_idx) {
    Error(Nil) -> #(blocks, end_idx - file_len)
    Ok(free_start_idx) -> #(
      move_file(blocks, file_start_idx, free_start_idx, file_id, file_len),
      end_idx - file_len,
    )
  }
}

fn find_file(blocks, file_id, idx) {
  case idx < 0 {
    True -> panic
    False ->
      case dict.get(blocks, idx) {
        Error(Nil) | Ok(Free) -> find_file(blocks, file_id, idx - 1)
        Ok(File(found_id)) ->
          case found_id == file_id {
            False -> find_file(blocks, file_id, idx - 1)
            True -> collect_file(blocks, file_id, idx, 0)
          }
      }
  }
}

fn collect_file(blocks, file_id, idx, len) {
  case dict.get(blocks, idx) {
    Error(Nil) | Ok(Free) -> #(idx + 1, len)
    Ok(File(found_id)) ->
      case found_id == file_id {
        False -> #(idx + 1, len)
        True -> collect_file(blocks, file_id, idx - 1, len + 1)
      }
  }
}

fn find_free(blocks, len, idx, before_idx) {
  case idx + len > before_idx {
    True -> Error(Nil)
    False ->
      case dict.get(blocks, idx) {
        Error(Nil) | Ok(File(_)) -> find_free(blocks, len, idx + 1, before_idx)
        Ok(Free) ->
          case verify_free(blocks, len, idx, before_idx) {
            False -> find_free(blocks, len, idx + 1, before_idx)
            True -> Ok(idx)
          }
      }
  }
}

fn verify_free(blocks, len, idx, before_idx) {
  case len <= 0 {
    True -> True
    False ->
      case idx >= before_idx {
        True -> False
        False ->
          case dict.get(blocks, idx) {
            Error(Nil) | Ok(File(_)) -> False
            Ok(Free) -> verify_free(blocks, len - 1, idx + 1, before_idx)
          }
      }
  }
}

fn move_file(blocks, file_idx, free_idx, file_id, len) {
  case len <= 0 {
    True -> blocks
    False ->
      blocks
      |> dict.insert(free_idx, File(file_id))
      |> dict.insert(file_idx, Free)
      |> move_file(file_idx + 1, free_idx + 1, file_id, len - 1)
  }
}
