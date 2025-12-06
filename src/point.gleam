import gleam/list

pub type Point {
  Point(x: Int, y: Int, v: String)
}

pub fn neighbors(p: Point) -> List(#(Int, Int)) {
  [
    #(p.x - 1, p.y - 1),
    #(p.x, p.y - 1),
    #(p.x + 1, p.y - 1),
    #(p.x - 1, p.y),
    #(p.x + 1, p.y),
    #(p.x - 1, p.y + 1),
    #(p.x, p.y + 1),
    #(p.x + 1, p.y + 1),
  ]
  |> list.filter(fn(a: #(Int, Int)) {
    let #(x, y) = a
    x >= 0 && y >= 0
  })
}
