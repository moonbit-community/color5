///|
/// Test suite for the colors library using separate types per color space
test "rgb creation and clamping" {
  let red = @colors.rgb(255, 0, 0)
  let _green = @colors.rgb(0, 255, 0)
  let _blue = @colors.rgb(0, 0, 255)
  let white = @colors.rgb(255, 255, 255)
  let black = @colors.rgb(0, 0, 0)
  inspect(red, content="RGBColor({ {r: 255, g: 0, b: 0 }})")
  inspect(white, content="RGBColor({ {r: 255, g: 255, b: 255 }})")
  inspect(black, content="RGBColor({ {r: 0, g: 0, b: 0 }})")

  // Test clamping
  let clamped_high = @colors.rgb(300, 400, 500)
  let clamped_low = @colors.rgb(-50, -100, -200)
  let clamped_mixed = @colors.rgb(300, 128, -50)
  inspect(clamped_high, content="RGBColor({ {r: 255, g: 255, b: 255 }})")
  inspect(clamped_low, content="RGBColor({ {r: 0, g: 0, b: 0 }})")
  inspect(clamped_mixed, content="RGBColor({ {r: 255, g: 128, b: 0 }})")
}

///|
test "linear rgb creation and clamping" {
  let linear_red = @colors.linear_rgb(1.0, 0.0, 0.0)
  let _linear_green = @colors.linear_rgb(0.0, 1.0, 0.0)
  let _linear_blue = @colors.linear_rgb(0.0, 0.0, 1.0)
  let linear_white = @colors.linear_rgb(1.0, 1.0, 1.0)
  let linear_black = @colors.linear_rgb(0.0, 0.0, 0.0)
  inspect(linear_red, content="LinearRGBColor({ {r: 1, g: 0, b: 0 }})")
  inspect(linear_white, content="LinearRGBColor({ {r: 1, g: 1, b: 1 }})")
  inspect(linear_black, content="LinearRGBColor({ {r: 0, g: 0, b: 0 }})")

  // Test clamping
  let clamped_high = @colors.linear_rgb(2.0, 3.0, 4.0)
  let clamped_low = @colors.linear_rgb(-1.0, -2.0, -3.0)
  let clamped_mixed = @colors.linear_rgb(2.0, 0.5, -1.0)
  inspect(clamped_high, content="LinearRGBColor({ {r: 1, g: 1, b: 1 }})")
  inspect(clamped_low, content="LinearRGBColor({ {r: 0, g: 0, b: 0 }})")
  inspect(clamped_mixed, content="LinearRGBColor({ {r: 1, g: 0.5, b: 0 }})")
}

///|
test "xyz color creation" {
  let xyz_white = @colors.xyz(95.047, 100.0, 108.883) // D65 white point
  let xyz_black = @colors.xyz(0.0, 0.0, 0.0)
  let xyz_red = @colors.xyz(41.24, 21.26, 1.93) // Approximate red
  inspect(xyz_white, content="XYZColor({ {x: 95.047, y: 100, z: 108.883 }})")
  inspect(xyz_black, content="XYZColor({ {x: 0, y: 0, z: 0 }})")
  inspect(xyz_red, content="XYZColor({ {x: 41.24, y: 21.26, z: 1.93 }})")
}

///|
test "luv color creation" {
  let luv_white = @colors.luv(100.0, 0.0, 0.0) // L*=100 for white
  let luv_black = @colors.luv(0.0, 0.0, 0.0) // L*=0 for black
  let luv_red = @colors.luv(53.24, 175.05, 37.75) // Approximate red
  inspect(luv_white, content="LUVColor({ {l: 100, u: 0, v: 0 }})")
  inspect(luv_black, content="LUVColor({ {l: 0, u: 0, v: 0 }})")
  inspect(luv_red, content="LUVColor({ {l: 53.24, u: 175.05, v: 37.75 }})")
}

///|
test "rgb to linear conversion" {
  let rgb_red = @colors.rgb(255, 0, 0)
  let linear_red = @colors.rgb_to_linear(rgb_red)

  // Check that conversion produces reasonable values
  match linear_red {
    { r, g, b } => {
      let r_reasonable = r > 0.9 && r <= 1.0
      let g_zero = g == 0.0
      let b_zero = b == 0.0
      inspect(r_reasonable, content="true")
      inspect(g_zero, content="true")
      inspect(b_zero, content="true")
    }
  }

  // Test gamma correction - middle gray should not be 0.5 in linear space
  let rgb_mid = @colors.rgb(128, 128, 128)
  let linear_mid = @colors.rgb_to_linear(rgb_mid)
  match linear_mid {
    { r, g: _, b: _ } => {
      // Due to gamma correction, 128/255 ≈ 0.5 in sRGB should be ~0.22 in linear
      let gamma_corrected = r < 0.3 && r > 0.1
      inspect(gamma_corrected, content="true")
    }
  }
}

///|
test "linear to rgb conversion" {
  let linear = @colors.linear_rgb(1.0, 0.0, 0.0)
  let rgb_color = @colors.linear_to_rgb(linear)
  inspect(rgb_color, content="RGBColor({ {r: 255, g: 0, b: 0 }})")

  // Test round-trip conversion
  let original_rgb = @colors.rgb(200, 150, 100)
  let to_linear = @colors.rgb_to_linear(original_rgb)
  let back_to_rgb = @colors.linear_to_rgb(to_linear)

  // Should be very close to original (within rounding error)
  match (original_rgb, back_to_rgb) {
    ({ r: r1, g: g1, b: b1 }, { r: r2, g: g2, b: b2 }) => {
      let r_close = (r1 - r2).abs() <= 1
      let g_close = (g1 - g2).abs() <= 1
      let b_close = (b1 - b2).abs() <= 1
      inspect(r_close, content="true")
      inspect(g_close, content="true")
      inspect(b_close, content="true")
    }
  }
}

///|
test "linear to xyz conversion" {
  let linear_white = @colors.linear_rgb(1.0, 1.0, 1.0)
  let xyz_white = @colors.linear_to_xyz(linear_white)

  // Should be close to D65 white point
  match xyz_white {
    { x, y, z } => {
      let x_close = (x - 95.047).abs() < 1.0
      let y_close = (y - 100.0).abs() < 1.0
      let z_close = (z - 108.883).abs() < 1.0
      inspect(x_close, content="true")
      inspect(y_close, content="true")
      inspect(z_close, content="true")
    }
  }
}

///|
test "xyz to linear conversion" {
  let xyz_white = @colors.xyz(95.047, 100.0, 108.883)
  let linear_white = @colors.xyz_to_linear(xyz_white)

  // Should be close to (1, 1, 1)
  match linear_white {
    { r, g, b } => {
      let r_close = (r - 1.0).abs() < 0.1
      let g_close = (g - 1.0).abs() < 0.1
      let b_close = (b - 1.0).abs() < 0.1
      inspect(r_close, content="true")
      inspect(g_close, content="true")
      inspect(b_close, content="true")
    }
  }
}

///|
test "xyz to luv conversion" {
  let xyz_white = @colors.xyz(95.047, 100.0, 108.883)
  let luv_white = @colors.xyz_to_luv(xyz_white)

  // White point should have L*=100, u*≈0, v*≈0
  match luv_white {
    { l, u, v } => {
      let l_correct = (l - 100.0).abs() < 1.0
      let u_small = u.abs() < 1.0
      let v_small = v.abs() < 1.0
      inspect(l_correct, content="true")
      inspect(u_small, content="true")
      inspect(v_small, content="true")
    }
  }
}

///|
test "luv to xyz conversion" {
  let luv_white = @colors.luv(100.0, 0.0, 0.0)
  let xyz_white = @colors.luv_to_xyz(luv_white)

  // Should be close to D65 white point
  match xyz_white {
    { x, y, z } => {
      let x_close = (x - 95.047).abs() < 1.0
      let y_close = (y - 100.0).abs() < 1.0
      let z_close = (z - 108.883).abs() < 1.0
      inspect(x_close, content="true")
      inspect(y_close, content="true")
      inspect(z_close, content="true")
    }
  }
}

///|
test "rgb blending" {
  let red = @colors.rgb(255, 0, 0)
  let blue = @colors.rgb(0, 0, 255)
  let purple = @colors.rgb_blend(red, blue, 0.5)
  inspect(purple, content="RGBColor({ {r: 128, g: 0, b: 128 }})")
  let mostly_red = @colors.rgb_blend(red, blue, 0.25)
  inspect(mostly_red, content="RGBColor({ {r: 192, g: 0, b: 64 }})")
  let mostly_blue = @colors.rgb_blend(red, blue, 0.75)
  inspect(mostly_blue, content="RGBColor({ {r: 64, g: 0, b: 192 }})")

  // Test edge cases
  let all_red = @colors.rgb_blend(red, blue, 0.0)
  let all_blue = @colors.rgb_blend(red, blue, 1.0)
  inspect(all_red, content="RGBColor({ {r: 255, g: 0, b: 0 }})")
  inspect(all_blue, content="RGBColor({ {r: 0, g: 0, b: 255 }})")

  // Test clamping of mix parameter
  let clamped_low = @colors.rgb_blend(red, blue, -0.5)
  let clamped_high = @colors.rgb_blend(red, blue, 1.5)
  inspect(clamped_low, content="RGBColor({ {r: 255, g: 0, b: 0 }})")
  inspect(clamped_high, content="RGBColor({ {r: 0, g: 0, b: 255 }})")
}

///|
test "linear rgb blending" {
  let linear_red = @colors.linear_rgb(1.0, 0.0, 0.0)
  let linear_blue = @colors.linear_rgb(0.0, 0.0, 1.0)
  let linear_purple = @colors.linear_blend(linear_red, linear_blue, 0.5)
  inspect(linear_purple, content="LinearRGBColor({ {r: 0.5, g: 0, b: 0.5 }})")
  let mostly_red = @colors.linear_blend(linear_red, linear_blue, 0.25)
  inspect(mostly_red, content="LinearRGBColor({ {r: 0.75, g: 0, b: 0.25 }})")
}

///|
test "universal rgb conversion" {
  let rgb_color = @colors.rgb(255, 128, 64)
  let linear_color = @colors.linear_rgb(0.8, 0.6, 0.4)
  let xyz_color = @colors.xyz(50.0, 60.0, 70.0)
  let luv_color = @colors.luv(75.0, 25.0, -15.0)

  // All should convert to RGB
  let rgb1 = @colors.rgb_to_rgb(rgb_color)
  let rgb2 = @colors.linear_rgb_to_rgb(linear_color)
  let _rgb3 = @colors.xyz_to_rgb(xyz_color)
  let _rgb4 = @colors.luv_to_rgb(luv_color)

  // Original RGB should be unchanged
  inspect(rgb1, content="RGBColor({ {r: 255, g: 128, b: 64 }})")

  // Others should produce valid RGB colors
  match rgb2 {
    { r, g, b } => {
      let valid_r = r >= 0 && r <= 255
      let valid_g = g >= 0 && g <= 255
      let valid_b = b >= 0 && b <= 255
      inspect(valid_r, content="true")
      inspect(valid_g, content="true")
      inspect(valid_b, content="true")
    }
  }
}

///|
test "universal linear rgb conversion" {
  let rgb_color = @colors.rgb(255, 128, 64)
  let linear_color = @colors.linear_rgb(0.8, 0.6, 0.4)
  let xyz_color = @colors.xyz(50.0, 60.0, 70.0)
  let luv_color = @colors.luv(75.0, 25.0, -15.0)

  // All should convert to LinearRGB
  let linear1 = @colors.rgb_to_linear_rgb(rgb_color)
  let linear2 = @colors.linear_rgb_to_linear_rgb(linear_color)
  let _linear3 = @colors.xyz_to_linear_rgb(xyz_color)
  let _linear4 = @colors.luv_to_linear_rgb(luv_color)

  // Original LinearRGB should be unchanged
  inspect(linear2, content="LinearRGBColor({ {r: 0.8, g: 0.6, b: 0.4 }})")

  // Others should produce valid LinearRGB colors
  match linear1 {
    { r, g, b } => {
      let valid_r = r >= 0.0 && r <= 1.0
      let valid_g = g >= 0.0 && g <= 1.0
      let valid_b = b >= 0.0 && b <= 1.0
      inspect(valid_r, content="true")
      inspect(valid_g, content="true")
      inspect(valid_b, content="true")
    }
  }
}

///|
test "universal xyz conversion" {
  let rgb_color = @colors.rgb(255, 128, 64)
  let linear_color = @colors.linear_rgb(0.8, 0.6, 0.4)
  let xyz_color = @colors.xyz(50.0, 60.0, 70.0)
  let luv_color = @colors.luv(75.0, 25.0, -15.0)

  // All should convert to XYZ
  let xyz1 = @colors.rgb_to_xyz(rgb_color)
  let _xyz2 = @colors.linear_rgb_to_xyz(linear_color)
  let xyz3 = @colors.xyz_to_xyz(xyz_color)
  let _xyz4 = @colors.luv_to_xyz_color(luv_color)

  // Original XYZ should be unchanged
  inspect(xyz3, content="XYZColor({ {x: 50, y: 60, z: 70 }})")

  // Others should produce valid XYZ colors
  match xyz1 {
    { x, y, z } => {
      let valid_x = x >= 0.0
      let valid_y = y >= 0.0
      let valid_z = z >= 0.0
      inspect(valid_x, content="true")
      inspect(valid_y, content="true")
      inspect(valid_z, content="true")
    }
  }
}

///|
test "universal luv conversion" {
  let rgb_color = @colors.rgb(255, 128, 64)
  let linear_color = @colors.linear_rgb(0.8, 0.6, 0.4)
  let xyz_color = @colors.xyz(50.0, 60.0, 70.0)
  let luv_color = @colors.luv(75.0, 25.0, -15.0)

  // All should convert to LUV
  let luv1 = @colors.rgb_to_luv(rgb_color)
  let _luv2 = @colors.linear_rgb_to_luv(linear_color)
  let _luv3 = @colors.xyz_to_luv_color(xyz_color)
  let luv4 = @colors.luv_to_luv(luv_color)

  // Original LUV should be unchanged
  inspect(luv4, content="LUVColor({ {l: 75, u: 25, v: -15 }})")

  // Others should produce valid LUV colors
  match luv1 {
    { l, u: _, v: _ } => {
      let valid_l = l >= 0.0 && l <= 100.0
      inspect(valid_l, content="true")
    }
  }
}

///|
test "chained conversions" {
  let original_rgb = @colors.rgb(200, 150, 100)

  // Chain through all color spaces and back
  let final_rgb = original_rgb
    |> @colors.rgb_to_linear
    |> @colors.linear_to_xyz
    |> @colors.xyz_to_luv
    |> @colors.luv_to_xyz
    |> @colors.xyz_to_linear
    |> @colors.linear_to_rgb

  // Should be close to original (within rounding error)
  match (original_rgb, final_rgb) {
    ({ r: r1, g: g1, b: b1 }, { r: r2, g: g2, b: b2 }) => {
      let r_close = (r1 - r2).abs() <= 2 // Allow for some rounding error
      let g_close = (g1 - g2).abs() <= 2
      let b_close = (b1 - b2).abs() <= 2
      inspect(r_close, content="true")
      inspect(g_close, content="true")
      inspect(b_close, content="true")
    }
  }
}

///|
test "edge cases" {
  // Test black color through all conversions
  let black_rgb = @colors.rgb(0, 0, 0)
  let black_linear = @colors.rgb_to_linear(black_rgb)
  let black_xyz = @colors.linear_to_xyz(black_linear)
  let black_luv = @colors.xyz_to_luv(black_xyz)
  inspect(black_linear, content="LinearRGBColor({ {r: 0, g: 0, b: 0 }})")
  inspect(black_xyz, content="XYZColor({ {x: 0, y: 0, z: 0 }})")
  inspect(black_luv, content="LUVColor({ {l: 0, u: 0, v: 0 }})")

  // Test white color through all conversions
  let white_rgb = @colors.rgb(255, 255, 255)
  let white_linear = @colors.rgb_to_linear(white_rgb)
  let white_xyz = @colors.linear_to_xyz(white_linear)
  let white_luv = @colors.xyz_to_luv(white_xyz)

  // White should have L* close to 100
  match white_luv {
    { l, u: _, v: _ } => {
      let l_close_to_100 = (l - 100.0).abs() < 1.0
      inspect(l_close_to_100, content="true")
    }
  }
}

///|
test "trait-based API" {
  // Demonstrate the new trait-based API that reduces the API surface
  let rgb_color = @colors.rgb(255, 128, 64)
  let xyz_color = @colors.xyz(50.0, 60.0, 70.0)
  let luv_color = @colors.luv(75.0, 25.0, -15.0)

  // Now we can use the same method name for all types!
  let _rgb_from_rgb = rgb_color.to_rgb() // Identity conversion
  let _rgb_from_xyz = xyz_color.to_rgb() // XYZ -> RGB
  let _rgb_from_luv = luv_color.to_rgb() // LUV -> RGB

  // All types can convert to any other type using the same method names
  let _linear_from_rgb = rgb_color.to_linear_rgb()
  let _linear_from_xyz = xyz_color.to_linear_rgb()
  let _linear_from_luv = luv_color.to_linear_rgb()
  let _xyz_from_rgb = rgb_color.to_xyz()
  let _xyz_from_luv = luv_color.to_xyz()
  let _luv_from_rgb = rgb_color.to_luv()
  let _luv_from_xyz = xyz_color.to_luv()

  // Blending works with trait methods too
  let red = @colors.rgb(255, 0, 0)
  let blue = @colors.rgb(0, 0, 255)
  let purple = red.blend(blue, 0.5)
  inspect(purple, content="RGBColor({ {r: 128, g: 0, b: 128 }})")

  // Linear blending
  let linear_red = @colors.linear_rgb(1.0, 0.0, 0.0)
  let linear_blue = @colors.linear_rgb(0.0, 0.0, 1.0)
  let linear_purple = linear_red.blend(linear_blue, 0.5)
  inspect(linear_purple, content="LinearRGBColor({ {r: 0.5, g: 0, b: 0.5 }})")
}
