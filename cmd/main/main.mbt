///|
fn main {
  println("Colors Library Demo")

  // Create some colors
  let red = @colors.Color::rgb(255, 0, 0)
  let green = @colors.Color::rgb(0, 255, 0)
  let blue = @colors.Color::rgb(0, 0, 255)

  // Blend colors
  let purple = @colors.Color::blend_rgb(red, blue, 0.5)
  let yellow = @colors.Color::blend_rgb(red, green, 0.5)

  // Convert to different color spaces
  let red_linear = red.as_linear_rgb()
  let red_xyz = red.as_xyz()
  let red_luv = red.as_luv()
  println("Red RGB: \{red}")
  println("Red LinearRGB: \{red_linear}")
  println("Red XYZ: \{red_xyz}")
  println("Red LUV: \{red_luv}")
  println("Purple (red + blue): \{purple}")
  println("Yellow (red + green): \{yellow}")
}
