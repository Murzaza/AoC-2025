pub fn at(l: List(t), n: Int) -> Result(t, Nil) {
  case l {
    [] -> Error(Nil)
    [head, ..rest] -> {
      case n {
        0 -> Ok(head)
        _ -> at(rest, n - 1)
      }
    }
  }
}
