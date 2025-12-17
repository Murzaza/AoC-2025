import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import point.{type Point}
import simplifile
import util.{at}

fn parse_file(contents: String) -> List(point.Point) {
  contents
  |> string.trim
  |> string.split("\n")
  |> list.map(fn(line) {
    let #(x, y) = line |> string.split_once(",") |> result.unwrap(#("-1", "-1"))
    let x = x |> int.parse |> result.unwrap(-1)
    let y = y |> int.parse |> result.unwrap(-1)

    point.Point(x, y, "")
  })
}

pub fn p1() {
  io.println("Part 1: " <> int.to_string(part1("files/day9.txt")))
}

pub fn part1(file: String) -> Int {
  let assert Ok(contents) = simplifile.read(file)
  let points = parse_file(contents)

  points
  |> list.combination_pairs
  |> list.map(fn(x) {
    let #(a, b) = x
    a |> point.inclusive_area(b)
  })
  |> list.max(int.compare)
  |> result.unwrap(0)
}

pub fn p2() {
  io.println("Part 2: " <> int.to_string(part2("files/day9.txt")))
}

pub fn part2(file: String) -> Int {
  let assert Ok(contents) = simplifile.read(file)
  let points = parse_file(contents)

  points
  |> list.combination_pairs
  |> list.map(fn(x) {
    let #(a, b) = x
    #(point.inclusive_area(a, b), a, b)
  })
  |> list.sort(fn(x, y) {
    let #(x_area, _, _) = x
    let #(y_area, _, _) = y

    int.compare(x_area, y_area)
  })
  |> list.reverse
  |> list.fold_until(0, fn(_acc, x) {
    let #(area, p1, p2) = x

    let rect = rectangle_from_points(p1, p2)
    let in_polygon = rectangle_in_polygon(rect, points)

    case in_polygon {
      False -> list.Continue(0)
      True -> list.Stop(area)
    }
  })
}

pub type Rectangle {
  Rectangle(min_x: Int, min_y: Int, max_x: Int, max_y: Int)
}

pub fn rectangle_from_points(p1: Point, p2: Point) -> Rectangle {
  Rectangle(
    min_x: int.min(p1.x, p2.x),
    min_y: int.min(p1.y, p2.y),
    max_x: int.max(p1.x, p2.x),
    max_y: int.max(p1.y, p2.y),
  )
}

pub fn rectangle_area(rect: Rectangle) -> Int {
  { rect.max_x - rect.min_x } * { rect.max_y - rect.min_y }
}

pub fn rectangle_in_polygon(rect: Rectangle, polygon: List(Point)) -> Bool {
  let corners_inside =
    point_in_polygon(point.Point(rect.min_x, rect.min_y, ""), polygon)
    && point_in_polygon(point.Point(rect.max_x, rect.min_y, ""), polygon)
    && point_in_polygon(point.Point(rect.max_x, rect.max_y, ""), polygon)
    && point_in_polygon(point.Point(rect.min_x, rect.max_y, ""), polygon)

  case corners_inside {
    False -> False
    True -> {
      !polygon_edge_cuts_rectangle(polygon, rect)
    }
  }
}

fn polygon_edge_cuts_rectangle(polygon: List(Point), rect: Rectangle) -> Bool {
  case polygon {
    [] | [_] -> False
    _ -> {
      let n = list.length(polygon)
      check_edge_cuts(polygon, rect, n, 0)
    }
  }
}

fn check_edge_cuts(
  polygon: List(Point),
  rect: Rectangle,
  n: Int,
  i: Int,
) -> Bool {
  case i < n {
    False -> False
    True -> {
      let assert Ok(p1) = polygon |> at(i)
      let assert Ok(p2) = polygon |> at({ i + 1 } % n)

      case edge_cuts_rectangle_interior(p1, p2, rect) {
        True -> True
        False -> check_edge_cuts(polygon, rect, n, i + 1)
      }
    }
  }
}

fn edge_cuts_rectangle_interior(p1: Point, p2: Point, rect: Rectangle) -> Bool {
  case p1.x == p2.x {
    True -> {
      let seg_x = p1.x
      let seg_min_y = int.min(p1.y, p2.y)
      let seg_max_y = int.max(p1.y, p2.y)

      seg_x > rect.min_x
      && seg_x < rect.max_x
      && seg_max_y > rect.min_y
      && seg_min_y < rect.max_y
    }
    False -> {
      let seg_y = p1.y
      let seg_min_x = int.min(p1.x, p2.x)
      let seg_max_x = int.max(p1.x, p2.x)

      seg_y > rect.min_y
      && seg_y < rect.max_y
      && seg_max_x > rect.min_x
      && seg_min_x < rect.max_x
    }
  }
}

pub fn point_in_polygon(point: Point, polygon: List(Point)) -> Bool {
  case polygon {
    [] | [_] | [_, _] -> False
    _ -> {
      let n = list.length(polygon)
      case check_on_boundary(point, polygon, n, 0) {
        True -> True
        False -> ray_cast_check(point, polygon, n, 0, False)
      }
    }
  }
}

fn ray_cast_check(
  point: Point,
  polygon: List(Point),
  n: Int,
  i: Int,
  inside: Bool,
) -> Bool {
  case i < n {
    False -> inside
    True -> {
      let assert Ok(p1) = at(polygon, i)
      let assert Ok(p2) = at(polygon, { i + 1 } % n)

      let new_inside = case crosses_ray(point, p1, p2) {
        True -> !inside
        False -> inside
      }

      ray_cast_check(point, polygon, n, i + 1, new_inside)
    }
  }
}

fn crosses_ray(point: Point, p1: Point, p2: Point) -> Bool {
  case p1.x == p2.x {
    False -> False
    True -> {
      let edge_x = p1.x
      let min_y = int.min(p1.y, p2.y)
      let max_y = int.max(p1.y, p2.y)

      edge_x > point.x && point.y >= min_y && point.y < max_y
    }
  }
}

fn check_on_boundary(point: Point, polygon: List(Point), n: Int, i: Int) -> Bool {
  case i < n {
    False -> False
    True -> {
      let assert Ok(p1) = at(polygon, i)
      let assert Ok(p2) = at(polygon, { i + 1 } % n)

      case point_on_segment(point, p1, p2) {
        True -> True
        False -> check_on_boundary(point, polygon, n, i + 1)
      }
    }
  }
}

fn point_on_segment(point: Point, p1: Point, p2: Point) -> Bool {
  case p1.x == p2.x {
    True -> {
      let min_y = int.min(p1.y, p2.y)
      let max_y = int.max(p1.y, p2.y)
      point.x == p1.x && point.y >= min_y && point.y <= max_y
    }
    False -> {
      let min_x = int.min(p1.x, p2.x)
      let max_x = int.max(p1.x, p2.x)
      point.y == p1.y && point.x >= min_x && point.x <= max_x
    }
  }
}
