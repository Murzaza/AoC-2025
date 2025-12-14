import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import simplifile
import space

fn parse_file(contents: String) -> List(space.Space) {
  contents
  |> string.trim
  |> string.split("\n")
  |> list.map(fn(x) {
    case x |> string.split(",") {
      [x, y, z] -> {
        let x = int.parse(x) |> result.unwrap(0) |> int.to_float
        let y = int.parse(y) |> result.unwrap(0) |> int.to_float
        let z = int.parse(z) |> result.unwrap(0) |> int.to_float
        space.Space(x, y, z)
      }
      _ -> space.Space(0.0, 0.0, 0.0)
    }
  })
}

fn join_sets(
  sets: List(set.Set(space.Space)),
  new: set.Set(space.Space),
) -> List(set.Set(space.Space)) {
  case sets {
    [] -> [new]
    [head, ..rest] -> {
      case head |> set.is_disjoint(new) {
        True -> [head, ..join_sets(rest, new)]
        False -> join_sets(rest, new |> set.union(head))
      }
    }
  }
}

pub fn p1() {
  io.println("Part 1: " <> int.to_string(part1("files/day8.txt")))
}

pub fn part1(file: String) -> Int {
  let assert Ok(contents) = simplifile.read(file)
  let boxes = parse_file(contents)

  let to_take = case boxes |> list.length {
    a if a < 1000 -> 10
    _ -> 1000
  }

  boxes
  |> list.combination_pairs
  |> list.map(fn(x) {
    let #(a, b) = x
    let d = a |> space.distance(b)
    #(d, a, b)
  })
  |> list.sort(fn(a, b) {
    let #(da, _, _) = a
    let #(db, _, _) = b
    float.compare(da, db)
  })
  |> list.take(to_take)
  |> list.map(fn(x) {
    let #(_, a, b) = x
    [a, b] |> set.from_list
  })
  |> list.fold([], fn(acc, a) {
    case acc |> list.any(fn(b) { !set.is_disjoint(a, b) }) {
      False -> [a, ..acc]
      True -> join_sets(acc, a)
    }
  })
  |> list.sort(fn(a, b) {
    let a = a |> set.size
    let b = b |> set.size

    int.compare(a, b)
  })
  |> list.reverse
  |> list.take(3)
  |> list.fold(1, fn(acc, a) { acc * set.size(a) })
}

pub fn p2() {
  io.println("Part 2: " <> int.to_string(part2("files/day8.txt")))
}

pub fn part2(file: String) -> Int {
  let assert Ok(contents) = simplifile.read(file)
  let boxes = parse_file(contents)
  let disjoint_sets =
    boxes
    |> list.map(fn(a) { [a] |> set.from_list })

  let pairs =
    boxes
    |> list.combination_pairs
    |> list.map(fn(x) {
      let #(a, b) = x
      let d = a |> space.distance(b)
      #(d, a, b)
    })
    |> list.sort(fn(a, b) {
      let #(da, _, _) = a
      let #(db, _, _) = b
      float.compare(da, db)
    })
    |> list.map(fn(x) {
      let #(_, a, b) = x
      [a, b] |> set.from_list
    })

  let #(answer, _) =
    pairs
    |> list.fold_until(#(0.0, disjoint_sets), fn(acc, a) {
      let #(_, sets) = acc

      let merged = join_sets(sets, a)

      case list.length(merged) {
        1 -> {
          let assert [first, second] = a |> set.to_list
          let ans = first.x *. second.x
          list.Stop(#(ans, merged))
        }
        _ -> {
          list.Continue(#(0.0, merged))
        }
      }
    })

  answer |> float.truncate
}
