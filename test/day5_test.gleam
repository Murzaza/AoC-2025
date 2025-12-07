import day5
import gleam/int
import gleam/io

pub fn part1_test() {
  let ans = day5.part1("test/files/day5.txt")
  io.println("D5P1 Test: " <> int.to_string(ans))
  assert ans == 3
}

pub fn part2_test() {
  let ans = day5.part2("test/files/day5.txt")
  io.println("D5P2 Test: " <> int.to_string(ans))
  assert ans == 14
}
