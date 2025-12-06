import day2

import gleam/int
import gleam/io

pub fn part1_test() {
  let ans = day2.part1("test/files/day2.txt")
  io.println("D2P1 Test = " <> int.to_string(ans))
  assert ans == 1_227_775_554
}

pub fn part2_test() {
  let ans = day2.part2("test/files/day2.txt")
  io.println("D2P2 Test = " <> int.to_string(ans))
  assert ans == 4_174_379_265
}
