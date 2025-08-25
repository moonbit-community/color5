///|
fn main {
  println("Colors Library Demo")

  // Create some colors
  let red = @colors.rgb(255, 0, 0)
  let green = @colors.rgb(0, 255, 0)
  let blue = @colors.rgb(0, 0, 255)

  // Blend colors
  let purple = @colors.blend_rgb(red, blue, 0.5)
  let yellow = @colors.blend_rgb(red, green, 0.5)

  // Convert to different color spaces
  let red_linear = @colors.to_linear_rgb(red)
  let red_xyz = @colors.to_xyz(red)
  let red_luv = @colors.to_luv(red)
  println("Red RGB: \{red}")
  println("Red LinearRGB: \{red_linear}")
  println("Red XYZ: \{red_xyz}")
  println("Red LUV: \{red_luv}")
  println("Purple (red + blue): \{purple}")
  println("Yellow (red + green): \{yellow}")
}
