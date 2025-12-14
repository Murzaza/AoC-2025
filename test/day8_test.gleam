import day8
import gleam/int
import gleam/io

pub fn part1_test() {
  let ans = day8.part1("test/files/day8.txt")
  io.println("D8P1 test: " <> int.to_string(ans))
  assert ans == 40
}

pub fn part2_test() {
  let ans = day8.part2("test/files/day8.txt")
  io.println("D8P2 test: " <> int.to_string(ans))
  assert ans == 25_272
}
