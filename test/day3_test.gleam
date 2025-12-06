import day3

import gleam/int
import gleam/io

pub fn part1_test() {
  let ans = day3.part1("test/files/day3.txt")
  io.println("D3P1 Test = " <> int.to_string(ans))
  assert ans == 357
}

pub fn part2_test() {
  let ans = day3.part2("test/files/day3.txt")
  io.println("D3P2 Test = " <> int.to_string(ans))
  assert ans == 3_121_910_778_619
}
