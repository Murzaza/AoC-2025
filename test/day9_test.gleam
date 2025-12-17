import day9
import gleam/int
import gleam/io

pub fn part1_test() {
  let ans = day9.part1("test/files/day9.txt")
  io.println("D9P1 test: " <> int.to_string(ans))
  assert ans == 50
}

pub fn part2_test() {
  let ans = day9.part2("test/files/day9.txt")
  io.println("D9P2 test: " <> int.to_string(ans))
  assert ans == 24
}
