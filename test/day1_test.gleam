import day1

import gleam/int
import gleam/io

pub fn part1_test() {
  let ans = day1.part1("test/files/day1.txt")
  io.println("D1P1 Test: " <> int.to_string(ans))
  assert ans == 3
}

pub fn part2_test() {
  let ans = day1.part2("test/files/day1.txt")
  io.println("D1P2 Test: " <> int.to_string(ans))
  assert ans == 6
}
