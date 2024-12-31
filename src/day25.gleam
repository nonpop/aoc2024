import gleam/list
import gleam/string
import util

pub fn main() {
  util.run(solve1, solve2)
}

fn solve1(lines) {
  let #(locks, keys) = parse(lines)

  let combos = {
    use lock <- list.flat_map(locks)
    use key <- list.map(keys)
    #(lock, key)
  }

  combos
  |> list.filter(fn(p) { fits(p.0, p.1) })
  |> list.length
  |> util.print_int
}

fn solve2(_) {
  panic as "day 25 has no part 2"
}

fn fits(lock: Lock, key: Key) {
  list.zip(lock.pins, key.shape)
  |> list.map(fn(p) { p.0 + p.1 })
  |> list.filter(fn(s) { s > 5 })
  |> list.is_empty
}

type Lock {
  Lock(pins: List(Int))
}

type Key {
  Key(shape: List(Int))
}

fn parse(lines) {
  let items =
    lines
    |> string.join(with: "\n")
    |> string.split(on: "\n\n")
    |> list.map(string.split(_, on: "\n"))
    |> list.map(list.filter(_, fn(line) { line != "" }))
    |> list.map(parse_item)

  let locks =
    items
    |> list.filter_map(fn(item) {
      case item {
        LockItem(lock) -> Ok(lock)
        KeyItem(_) -> Error(Nil)
      }
    })

  let keys =
    items
    |> list.filter_map(fn(item) {
      case item {
        LockItem(_) -> Error(Nil)
        KeyItem(key) -> Ok(key)
      }
    })

  #(locks, keys)
}

type Item {
  LockItem(Lock)
  KeyItem(Key)
}

fn parse_item(lines) {
  let assert [top, r1, r2, r3, r4, r5, bottom] = lines
  case top, bottom {
    "#####", "....." -> LockItem(Lock(pins: count_fills([r1, r2, r3, r4, r5])))
    ".....", "#####" -> KeyItem(Key(shape: count_fills([r1, r2, r3, r4, r5])))
    _, _ -> panic
  }
}

fn count_fills(rows) {
  list.range(0, 4)
  |> list.map(count_col_fills(_, rows))
}

fn count_col_fills(col, rows) {
  case rows {
    [] -> 0
    [r, ..rs] -> {
      let first = case r |> string.drop_start(col) |> string.first {
        Ok("#") -> 1
        Ok(".") -> 0
        _ -> panic
      }
      first + count_col_fills(col, rs)
    }
  }
}
