import gleam/float
import gleam/result

pub type Space {
  Space(x: Float, y: Float, z: Float)
}

pub fn distance(a: Space, b: Space) -> Float {
  let dx = float.power(b.x -. a.x, 2.0) |> result.unwrap(0.0)
  let dy = float.power(b.y -. a.y, 2.0) |> result.unwrap(0.0)
  let dz = float.power(b.z -. a.z, 2.0) |> result.unwrap(0.0)

  float.square_root(dx +. dy +. dz) |> result.unwrap(0.0)
}
