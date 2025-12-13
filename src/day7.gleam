import gleam/int
import gleam/io
import gleam/list
import gleam/string
import rememo/memo
import simplifile

fn parse_file(contents: String) -> #(Int, List(List(Int))) {
  let lines = contents |> string.trim |> string.split("\n")
  case lines {
    [] -> #(0, [])
    [start, ..rest] -> {
      let beam =
        start
        |> string.to_graphemes
        |> list.fold_until(from: 0, with: fn(acc, x) {
          case x == "S" {
            True -> list.Stop(acc)
            False -> list.Continue(acc + 1)
          }
        })

      let splitters =
        rest
        |> list.map(fn(line) {
          line
          |> string.to_graphemes
          |> list.index_map(fn(v: String, p: Int) {
            case v == "^" {
              True -> p
              False -> -1
            }
          })
          |> list.filter(fn(x) { x >= 0 })
        })
        |> list.filter(fn(x) {
          case x {
            [] -> False
            _ -> True
          }
        })

      #(beam, splitters)
    }
  }
}

fn splits(beam: Int, splitters: List(Int)) -> #(Int, List(Int)) {
  case splitters |> list.any(fn(x) { x == beam }) {
    True -> #(1, [beam - 1, beam + 1])
    False -> #(0, [beam])
  }
}

fn move_beams(beams: List(Int), splitters: List(List(Int))) -> Int {
  case splitters {
    [] -> 0
    [head, ..rest] -> {
      let #(times_split, new_beams) =
        beams
        |> list.map_fold(from: 0, with: fn(acc, beam) {
          let #(sp, nb) = splits(beam, head)
          #(acc + sp, nb)
        })

      move_beams(new_beams |> list.flatten |> list.unique, rest) + times_split
    }
  }
}

fn count_futures(
  beam: Int,
  level: Int,
  cache,
  splitters: List(List(Int)),
) -> Int {
  use <- memo.memoize(cache, #(beam, level))
  case splitters {
    [] -> 1
    [head, ..rest] -> {
      let #(_, beams) = splits(beam, head)
      beams |> list.map(count_futures(_, level + 1, cache, rest)) |> int.sum
    }
  }
}

pub fn p1() {
  io.println("Part 1: " <> int.to_string(part1("files/day7.txt")))
}

pub fn part1(file: String) -> Int {
  let assert Ok(contents) = simplifile.read(file)
  let #(beam, splitter) = parse_file(contents)

  move_beams([beam], splitter)
}

pub fn p2() {
  io.println("Part 2: " <> int.to_string(part2("files/day7.txt")))
}

pub fn part2(file: String) -> Int {
  let assert Ok(contents) = simplifile.read(file)
  let #(beam, splitter) = parse_file(contents)

  use cache <- memo.create()
  count_futures(beam, 0, cache, splitter)
}
