import day6
import gleam/int
import gleam/io

pub fn part1_test() {
  let ans = day6.part1("test/files/day6.txt")
  io.println("D6P1 Test: " <> int.to_string(ans))
  assert ans == 4_277_556
}

pub fn part2_test() {
  let ans = day6.part2("test/files/day6p2.txt")
  io.println("D6P2 Test: " <> int.to_string(ans))
  assert ans == 3_263_827
}
