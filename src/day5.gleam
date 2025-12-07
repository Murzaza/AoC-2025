import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

fn parse_file(contents: String) -> #(List(#(Int, Int)), List(Int)) {
  let #(ranges, ids) =
    contents
    |> string.trim
    |> string.split(on: "\n")
    |> list.split_while(fn(a) { string.length(a) > 0 })

  let range =
    ranges
    |> list.map(fn(a) {
      let assert Ok(#(b, e)) = string.split_once(a, "-")
      let assert Ok(begin) = int.parse(b)
      let assert Ok(end) = int.parse(e)

      #(begin, end)
    })

  // Trim out the blank from the beginning of this list
  let assert Ok(ids) = list.rest(ids)
  let id =
    ids
    |> list.map(fn(a) {
      let assert Ok(x) = int.parse(a)
      x
    })

  #(range, id)
}

pub fn p1() {
  io.println("Part 1: " <> int.to_string(part1("files/day5.txt")))
}

pub fn part1(file: String) -> Int {
  let assert Ok(contents) = simplifile.read(file)
  let #(ranges, ids) = parse_file(contents)

  ids
  |> list.count(fn(a) {
    ranges
    |> list.any(fn(b) {
      let #(begin, end) = b

      begin <= a && a <= end
    })
  })
}

fn merge(range_1: #(Int, Int), range_2: #(Int, Int)) -> Result(#(Int, Int), Nil) {
  let #(b1, e1) = range_1
  let #(b2, e2) = range_2

  case e1 >= b2 {
    False -> Error(Nil)
    True -> {
      Ok(#(b1, int.max(e1, e2)))
    }
  }
}

fn merge_ranges(
  ranges: List(#(Int, Int)),
  merged_ranges: List(#(Int, Int)),
) -> List(#(Int, Int)) {
  case ranges {
    [] -> merged_ranges
    [first, ..rest] -> {
      let new_merged_ranges = case
        list.any(merged_ranges, fn(r) {
          case merge(r, first) {
            Ok(_) -> True
            Error(_) -> False
          }
        })
      {
        False -> list.append(merged_ranges, [first])
        True ->
          merged_ranges
          |> list.fold(from: [], with: fn(acc, r) {
            case merge(r, first) {
              Ok(new) -> list.append(acc, [new])
              Error(_) -> list.append(acc, [r])
            }
          })
      }
      merge_ranges(rest, new_merged_ranges)
    }
  }
}

pub fn p2() {
  io.println("Part 2: " <> int.to_string(part2("files/day5.txt")))
}

pub fn part2(file: String) -> Int {
  let assert Ok(contents) = simplifile.read(file)
  let #(ranges, _) = parse_file(contents)

  ranges
  |> list.sort(fn(a, b) {
    let #(ba, _) = a
    let #(bb, _) = b
    int.compare(ba, bb)
  })
  |> merge_ranges([])
  |> list.fold(from: 0, with: fn(acc, r) {
    let #(begin, end) = r
    acc + 1 + end - begin
  })
}
