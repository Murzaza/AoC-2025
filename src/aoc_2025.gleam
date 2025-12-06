import argv
import clip.{type Command}
import clip/help
import clip/opt.{type Opt}
import gleam/int
import gleam/io
import gleam/list
import gleam/result

import day1
import day2
import day3

type Args {
  Args(day: Result(Int, Nil), part: Result(Int, Nil))
}

fn day_opt() -> Opt(Result(Int, Nil)) {
  opt.new("day")
  |> opt.short("d")
  |> opt.help("Day to run ( 1-12 )")
  |> opt.int
  |> opt.try_map(fn(day) {
    case day {
      d if d <= 12 && d >= 1 -> Ok(d)
      _ -> Error("Day must be between 1 and 12, inclusively")
    }
  })
  |> opt.optional
}

fn part_opt() -> Opt(Result(Int, Nil)) {
  opt.new("part")
  |> opt.short("p")
  |> opt.help("Part (1 | 2) to run. If not specified, all parts will be ran.")
  |> opt.int
  |> opt.try_map(fn(part) {
    case part {
      p if p <= 2 && p >= 1 -> Ok(p)
      _ -> Error("Part must be between 1 and 2, inclusively")
    }
  })
  |> opt.optional
}

fn command() -> Command(Args) {
  clip.command({
    use day <- clip.parameter
    use part <- clip.parameter

    Args(day, part)
  })
  |> clip.opt(day_opt())
  |> clip.opt(part_opt())
}

fn get_part(parts: List(fn() -> Nil), part: Int) -> fn() -> Nil {
  let default_fn = fn() { io.println("Bruh you goofed!") }
  case part {
    1 -> parts |> list.first |> result.unwrap(default_fn)
    2 -> parts |> list.last |> result.unwrap(default_fn)
    _ -> default_fn
  }
}

fn get_at(array: List(a), at: Int) -> Result(a, Nil) {
  case array {
    [h, ..rest] -> {
      case at {
        0 -> Ok(h)
        _ -> get_at(rest, at - 1)
      }
    }
    _ -> Error(Nil)
  }
}

pub fn main() -> Nil {
  let result =
    command()
    |> clip.help(help.simple("AoC", "Run the solution to AoC 2025 problems"))
    |> clip.run(argv.load().arguments)

  case result {
    Error(e) -> io.println_error(e)
    Ok(args) -> {
      let day = case args.day {
        Error(_) -> 0
        Ok(day) -> day
      }

      let part = case args.part {
        Error(_) -> 0
        Ok(part) -> part
      }

      // Solution functions. These will be the two parts to the solution
      // for each day. [[day1.part1, day1.part2], [day2.part1, day2.part2]]
      let solutions = [
        [day1.p1, day1.p2],
        [day2.p1, day2.p2],
        [day3.p1, day3.p2],
      ]

      case day {
        0 -> {
          io.println("Running all days and parts")
          solutions
          |> list.flatten
          |> list.each(fn(f) { f() })
        }
        _ if day <= 3 -> {
          io.println("Day " <> int.to_string(day))

          let idx = day - 1
          let parts = case get_at(solutions, idx) {
            Ok(x) -> x
            Error(Nil) -> {
              let error_fn = fn() {
                io.println(
                  "Error getting functions for day " <> int.to_string(day),
                )
              }

              [error_fn, error_fn]
            }
          }

          case part {
            0 -> {
              io.println("Running all parts")
              parts
              |> list.each(fn(f) { f() })
            }
            1 | 2 -> {
              let p = get_part(parts, part)
              p()
            }
            _ -> {
              io.println("Can't run part " <> int.to_string(part))
            }
          }
        }
        _ -> io.println("Those solutions aren't ready yet!")
      }
    }
  }
}
