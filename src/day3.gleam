import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

fn parse_file(contents: String) -> List(List(Int)) {
  contents
  |> string.trim
  |> string.split(on: "\n")
  |> list.map(fn(bank: String) -> List(Int) {
    bank
    |> string.to_graphemes
    |> list.map(fn(g) {
      let assert Ok(n) = int.parse(g)
      n
    })
  })
}

fn update_max(v: Int, max: List(Int)) -> List(Int) {
  case max {
    [] -> []
    [e, ..rest] -> {
      case v > e {
        True -> list.append([v], list.repeat(0, list.length(rest)))
        False -> list.append([e], update_max(v, rest))
      }
    }
  }
}

fn get_volts(bank: List(Int), bats: Int) -> List(Int) {
  bank
  |> list.index_fold(from: list.repeat(0, bats), with: fn(m, b, i) {
    let left = list.length(bank) - i

    let #(a, max) = list.split(m, bats - left)

    list.append(a, update_max(b, max))
  })
}

fn find_joltage(bank: List(Int), n: Int) -> Int {
  let jolts = get_volts(bank, n)
  jolts
  |> list.fold(from: 0, with: fn(acc, n) { acc * 10 + n })
}

pub fn p1() {
  io.println("Part 1: " <> int.to_string(part1("files/day3.txt")))
}

pub fn part1(file: String) -> Int {
  let assert Ok(contents) = simplifile.read(file)
  let banks = parse_file(contents)

  banks
  |> list.map(find_joltage(_, 2))
  |> int.sum
}

pub fn p2() {
  io.println("Part 2: " <> int.to_string(part2("files/day3.txt")))
}

pub fn part2(file: String) -> Int {
  let assert Ok(contents) = simplifile.read(file)
  let banks = parse_file(contents)

  banks
  |> list.map(find_joltage(_, 12))
  |> int.sum
}
