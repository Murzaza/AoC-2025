import day4

import gleam/int
import gleam/io

pub fn part1_test() {
  let ans = day4.part1("test/files/day4.txt")
  io.println("D4P1 Test = " <> int.to_string(ans))
  assert ans == 13
}

pub fn part2_test() {
  let ans = day4.part2("test/files/day4.txt")
  io.println("D4P4 Test: " <> int.to_string(ans))
  assert ans == 43
}
