import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

fn parse_file(contents: String) -> List(fn(Int) -> Int) {
  contents
  |> string.split(on: "\n")
  |> list.map(fn(line: String) -> fn(Int) -> Int {
    case line {
      "L" <> turn -> {
        let assert Ok(t) = int.parse(turn)
        left(t, _)
      }
      "R" <> turn -> {
        let assert Ok(t) = int.parse(turn)
        right(t, _)
      }
      _ -> fn(x: Int) -> Int { x }
    }
  })
}

fn parse_file2(contents: String) -> List(fn(Int) -> #(Int, Int)) {
  contents
  |> string.split(on: "\n")
  |> list.map(fn(line: String) -> fn(Int) -> #(Int, Int) {
    case line {
      "L" <> turn -> {
        let assert Ok(t) = int.parse(turn)
        left2(t, _)
      }
      "R" <> turn -> {
        let assert Ok(t) = int.parse(turn)
        right2(t, _)
      }
      _ -> fn(x: Int) -> #(Int, Int) { #(x, 0) }
    }
  })
}

fn left(turn: Int, acc: Int) -> Int {
  let a = acc - turn
  case a % 100 {
    a if a >= 0 -> a
    _ -> 100 + a
  }
}

fn right(turn: Int, acc: Int) -> Int {
  let a = acc + turn

  case a % 100 {
    a if a <= 99 -> a
    _ -> a - 100
  }
}

fn left2(turn: Int, acc: Int) -> #(Int, Int) {
  let a = acc - turn
  let zeros = int.absolute_value(a / 100)
  let zeros = case a {
    _ if a <= 0 && acc != 0 -> zeros + 1
    _ -> zeros
  }
  case a % 100 {
    x if x >= 0 -> #(x, zeros)
    x -> #(100 + x, zeros)
  }
}

fn right2(turn: Int, acc: Int) -> #(Int, Int) {
  let a = acc + turn
  let zeros = a / 100
  case a % 100 {
    x if x <= 99 -> #(x, zeros)
    x -> #(x - 100, zeros)
  }
}

fn parse_zeros(acc: #(Int, Int), f: fn(Int) -> Int) -> #(Int, Int) {
  let a = acc.0
  let z = acc.1
  let res = f(a)
  let res_z = case res {
    0 -> z + 1
    _ -> z
  }

  #(res, res_z)
}

fn parse_passes(acc: #(Int, Int), f: fn(Int) -> #(Int, Int)) -> #(Int, Int) {
  let a = acc.0
  let z = acc.1

  let #(na, nz) = f(a)
  #(na, z + nz)
}

pub fn day1(file: String) {
  io.println("Day 1")
  io.println("\tPart1: " <> int.to_string(part1(file)))
}

pub fn p1() {
  io.println("Part 1: " <> int.to_string(part1("files/day1.txt")))
}

pub fn p2() {
  io.println("Part 2: " <> int.to_string(part2("files/day1.txt")))
}

pub fn part1(file: String) -> Int {
  let assert Ok(contents) = simplifile.read(file)
  let steps = parse_file(contents)

  let #(_, zeros) =
    steps
    |> list.fold(from: #(50, 0), with: parse_zeros)

  zeros
}

pub fn part2(file: String) -> Int {
  let assert Ok(contents) = simplifile.read(file)
  let steps = parse_file2(contents)

  let #(_, zeros) =
    steps
    |> list.fold(from: #(50, 0), with: parse_passes)

  zeros
}
