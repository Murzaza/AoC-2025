import day7
import gleam/int
import gleam/io

pub fn part1_test() {
  let ans = day7.part1("test/files/day7.txt")
  io.println("D7P1 test: " <> int.to_string(ans))
  assert ans == 21
}

pub fn part2_test() {
  let ans = day7.part2("test/files/day7.txt")
  io.println("D7P2 test: " <> int.to_string(ans))
  assert ans == 40
}
