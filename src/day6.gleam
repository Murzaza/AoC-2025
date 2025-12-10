import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

type Operation {
  Add(numbers: List(Int))
  Mul(numbers: List(Int))
}

fn do(op: Operation) -> Int {
  case op {
    Add(n) -> n |> int.sum
    Mul(n) -> n |> int.product
  }
}

fn column(l: List(List(String))) -> #(List(String), List(List(String))) {
  case l {
    [] -> #([], [])
    _ -> {
      let col =
        l
        |> list.map(list.first)
        |> list.map(result.unwrap(_, ""))

      let rest =
        l
        |> list.map(list.rest)
        |> list.map(result.unwrap(_, []))

      #(col, rest)
    }
  }
}

fn transpose(l: List(List(String))) -> List(List(String)) {
  let empty = l |> list.all(list.is_empty)
  case empty {
    True -> []
    False -> {
      let #(op, rest) = column(l)
      case rest {
        [] -> [op]
        _ -> list.append([op], transpose(rest))
      }
    }
  }
}

fn parse_file(contents: String) -> List(Operation) {
  let l =
    contents
    |> string.trim
    |> string.split("\n")
    |> list.map(string.trim)
    |> list.map(fn(a) { string.split(a, " ") })

  transpose(l)
  |> list.map(fn(a) {
    let #(nums, op) =
      a
      |> list.split_while(fn(x) { x != "+" && x != "*" })

    let numbers =
      nums
      |> list.map(fn(a) {
        let assert Ok(n) = int.parse(a)
        n
      })

    let assert [operator] = op
    case operator {
      "*" -> Mul(numbers)
      _ -> Add(numbers)
      // :D
    }
  })
}

fn width(l: List(List(String))) -> List(Int) {
  l
  |> list.map(fn(a) {
    a
    |> list.filter_map(fn(b) {
      case b {
        "" | " " -> Error(Nil)
        _ -> Ok(string.length(b))
      }
    })
  })
  |> list.transpose
  |> list.map(fn(x) { x |> list.max(int.compare) |> result.unwrap(0) })
}

fn take_from(n: Int, s: String) -> #(List(String), String) {
  let #(num, rest) = s |> string.to_graphemes |> list.split(n)
  // Remove the actual space
  let #(_, rest) = rest |> list.split(1)
  #(num, rest |> string.join("") |> string.trim_end)
}

fn create_math(
  w: List(Int),
  o: List(String),
  n: List(String),
) -> List(Operation) {
  case w, o {
    [], [] -> []
    [width, ..w_rest], [op, ..o_rest] -> {
      let #(nums, n_rest) =
        n
        |> list.fold([], fn(acc, s) { list.append(acc, [take_from(width, s)]) })
        |> list.unzip

      let ns =
        nums
        |> list.transpose
        |> list.map(fn(a) {
          a |> string.join("") |> string.trim |> int.parse |> result.unwrap(0)
        })

      let operation = case op {
        "+" -> Add(ns)
        "*" -> Mul(ns)
        _ -> Add(ns)
      }

      list.append([operation], create_math(w_rest, o_rest, n_rest))
    }
    _, _ -> []
  }
}

fn parse2(contents: String) -> List(Operation) {
  let nl =
    contents
    |> string.trim_end
    |> string.split("\n")

  let widths = nl |> list.map(fn(a) { a |> string.split(on: " ") }) |> width

  let ops =
    nl
    |> list.last
    |> result.unwrap("")
    |> string.split(on: " ")
    |> list.filter(fn(a) {
      case a {
        "" | " " -> False
        _ -> True
      }
    })

  let numbers =
    nl
    |> list.take(list.length(nl) - 1)

  assert list.length(widths) == list.length(ops)

  create_math(widths, ops, numbers)
}

pub fn p1() {
  io.println("Part 1: " <> int.to_string(part1("files/day6.txt")))
}

pub fn part1(file: String) -> Int {
  let assert Ok(contents) = simplifile.read(file)
  let ops = parse_file(contents)

  ops
  |> list.map(do)
  |> int.sum
}

pub fn p2() {
  io.println("Part 2: " <> int.to_string(part2("files/day6p2.txt")))
}

pub fn part2(file: String) -> Int {
  let assert Ok(contents) = simplifile.read(file)
  let ops = parse2(contents)

  ops
  |> list.map(do)
  |> int.sum
}
