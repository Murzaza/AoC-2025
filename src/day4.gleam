import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

import point

type Point =
  point.Point

fn parse_file(contents: String) -> List(Point) {
  contents
  |> string.trim
  |> string.split(on: "\n")
  |> list.index_map(fn(line: String, row: Int) -> List(Point) {
    line
    |> string.to_graphemes
    |> list.index_map(fn(v: String, col: Int) -> Point {
      point.Point(x: col, y: row, v: v)
    })
  })
  |> list.flatten
}

pub fn p1() {
  io.println("Part 1: " <> int.to_string(part1("files/day4.txt")))
}

pub fn part1(file: String) -> Int {
  let assert Ok(contents) = simplifile.read(file)
  let paper =
    parse_file(contents)
    |> list.filter(fn(x: Point) { x.v == "@" })

  paper
  |> list.count(fn(p: Point) {
    point.neighbors(p)
    |> list.count(fn(a: #(Int, Int)) {
      paper
      |> list.any(fn(b: Point) {
        let #(x, y) = a
        x == b.x && y == b.y
      })
    })
    < 4
  })
}

fn move_paper(paper: List(Point)) -> Int {
  let new =
    paper
    |> list.filter(fn(p: Point) {
      point.neighbors(p)
      |> list.count(fn(a: #(Int, Int)) {
        paper
        |> list.any(fn(b: Point) {
          let #(x, y) = a
          x == b.x && y == b.y
        })
      })
      >= 4
    })

  case list.length(paper) - list.length(new) {
    0 -> 0
    a -> move_paper(new) + a
  }
}

pub fn p2() {
  io.println("Part 2: " <> int.to_string(part2("files/day4.txt")))
}

pub fn part2(file: String) -> Int {
  let assert Ok(contents) = simplifile.read(file)
  let paper = parse_file(contents) |> list.filter(fn(x: Point) { x.v == "@" })

  move_paper(paper)
}
