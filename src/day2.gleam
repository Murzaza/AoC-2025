import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

fn parse_file(contents: String) -> List(#(Int, Int)) {
  contents
  |> string.trim
  |> string.split(on: ",")
  |> list.map(fn(range: String) -> #(Int, Int) {
    let assert [b, e] = range |> string.split(on: "-")
    let assert Ok(begin) = int.parse(b)
    let assert Ok(end) = int.parse(e)
    #(begin, end)
  })
}

fn sum_invalids(range: #(Int, Int)) -> Int {
  let #(curr, end) = range
  case curr {
    _ if curr > end -> 0
    _ -> {
      case is_invalid(curr) {
        True -> sum_invalids(#(curr + 1, end)) + curr
        False -> sum_invalids(#(curr + 1, end))
      }
    }
  }
}

pub fn is_invalid(n: Int) -> Bool {
  let s = int.to_string(n)
  case string.length(s) % 2 {
    0 -> {
      let half = string.length(s) / 2
      let a = string.slice(s, 0, half)
      let b = string.slice(s, half, half)
      a == b
    }
    _ -> False
  }
}

fn is_invalid2(n: Int) -> Bool {
  let s = int.to_string(n)
  check_invalid(s, 1)
}

fn all_equal(l: List(String)) -> Bool {
  case l {
    [] -> True
    [first, ..rest] -> list.all(rest, satisfying: fn(e) { e == first })
  }
}

fn check_invalid(s: String, subsize: Int) -> Bool {
  let len = string.length(s)
  case subsize > len / 2 {
    True -> False
    False -> {
      case len % subsize {
        0 -> {
          let chunks = len / subsize
          let substrings =
            list.range(0, chunks - 1)
            |> list.map(fn(i) {
              let start = i * subsize
              string.slice(s, start, subsize)
            })
          case all_equal(substrings) {
            True -> True
            False -> check_invalid(s, subsize + 1)
          }
        }
        _ -> check_invalid(s, subsize + 1)
      }
    }
  }
}

fn sum_invalids2(range: #(Int, Int)) -> Int {
  let #(curr, end) = range
  case curr {
    _ if curr > end -> 0
    _ -> {
      case is_invalid2(curr) {
        True -> sum_invalids2(#(curr + 1, end)) + curr
        False -> sum_invalids2(#(curr + 1, end))
      }
    }
  }
}

pub fn p1() {
  io.println("Part 1: " <> int.to_string(part1("files/day2.txt")))
}

pub fn part1(file: String) -> Int {
  let assert Ok(contents) = simplifile.read(file)
  let ranges = parse_file(contents)

  ranges
  |> list.fold(from: 0, with: fn(a: Int, r: #(Int, Int)) -> Int {
    let sum = sum_invalids(r)
    a + sum
  })
}

pub fn p2() {
  io.println("Part 2: " <> int.to_string(part2("files/day2.txt")))
}

pub fn part2(file: String) -> Int {
  let assert Ok(contents) = simplifile.read(file)
  let ranges = parse_file(contents)

  ranges
  |> list.fold(from: 0, with: fn(a: Int, r: #(Int, Int)) -> Int {
    let sum = sum_invalids2(r)
    a + sum
  })
}
