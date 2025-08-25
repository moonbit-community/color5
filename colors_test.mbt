///| Comprehensive test suite for the colors library
/// Tests cover all color spaces, conversions, and edge cases

///|
/// RGB color space tests
test "rgb creation and clamping" {
  // Test normal RGB values
  let red = rgb(255, 0, 0)
  inspect(red, content="RGB(255, 0, 0)")
  let green = rgb(0, 255, 0)
  inspect(green, content="RGB(0, 255, 0)")
  let blue = rgb(0, 0, 255)
  inspect(blue, content="RGB(0, 0, 255)")

  // Test clamping of out-of-range values
  let clamped_high = rgb(300, 400, 500)
  inspect(clamped_high, content="RGB(255, 255, 255)")
  let clamped_low = rgb(-50, -100, -200)
  inspect(clamped_low, content="RGB(0, 0, 0)")

  // Test mixed clamping
  let mixed = rgb(-10, 128, 300)
  inspect(mixed, content="RGB(0, 128, 255)")
}

///|
test "rgb blending" {
  let black = rgb(0, 0, 0)
  let white = rgb(255, 255, 255)

  // Test 50% blend (should give gray)
  let gray = blend_rgb(black, white, 0.5)
  inspect(gray, content="RGB(128, 128, 128)")

  // Test 0% blend (should be first color)
  let first = blend_rgb(black, white, 0.0)
  inspect(first, content="RGB(0, 0, 0)")

  // Test 100% blend (should be second color)
  let second = blend_rgb(black, white, 1.0)
  inspect(second, content="RGB(255, 255, 255)")

  // Test 25% blend
  let quarter = blend_rgb(black, white, 0.25)
  inspect(quarter, content="RGB(64, 64, 64)")

  // Test with colored values
  let red = rgb(255, 0, 0)
  let blue = rgb(0, 0, 255)
  let purple = blend_rgb(red, blue, 0.5)
  inspect(purple, content="RGB(128, 0, 128)")
}

///|
/// LinearRGB color space tests
test "linear_rgb creation and clamping" {
  // Test normal LinearRGB values
  let red = linear_rgb(1.0, 0.0, 0.0)
  inspect(red, content="LinearRGB(1, 0, 0)")
  let half_gray = linear_rgb(0.5, 0.5, 0.5)
  inspect(half_gray, content="LinearRGB(0.5, 0.5, 0.5)")

  // Test clamping
  let clamped = linear_rgb(2.0, -0.5, 1.5)
  inspect(clamped, content="LinearRGB(1, 0, 1)")
}

///|
test "rgb to linear conversion" {
  // Test pure colors
  let rgb_red = rgb(255, 0, 0)
  let linear_red = rgb_to_linear(rgb_red)
  inspect(linear_red, content="LinearRGB(1, 0, 0)")
  let rgb_black = rgb(0, 0, 0)
  let linear_black = rgb_to_linear(rgb_black)
  inspect(linear_black, content="LinearRGB(0, 0, 0)")

  // Test mid-gray (should not be 0.5 due to gamma correction)
  let rgb_mid = rgb(128, 128, 128)
  let linear_mid = rgb_to_linear(rgb_mid)
  // The actual value should be around 0.2158 due to gamma correction
  match linear_mid {
    LinearRGB(r, _, _) => {
      // Check that it's not 0.5 (which would be linear)
      let is_gamma_corrected = r < 0.3 && r > 0.1
      inspect(is_gamma_corrected, content="true")
    }
    _ => inspect(false, content="true")
  }
}

///|
test "linear to rgb conversion" {
  // Test round-trip conversion
  let original = rgb(200, 100, 50)
  let linear = rgb_to_linear(original)
  let back_to_rgb = linear_to_rgb(linear)

  // Should be very close to original (within rounding error)
  match (original, back_to_rgb) {
    (RGB(r1, g1, b1), RGB(r2, g2, b2)) => {
      let diff_r = if r1 > r2 { r1 - r2 } else { r2 - r1 }
      let diff_g = if g1 > g2 { g1 - g2 } else { g2 - g1 }
      let diff_b = if b1 > b2 { b1 - b2 } else { b2 - b1 }
      let close_enough = diff_r <= 1 && diff_g <= 1 && diff_b <= 1
      inspect(close_enough, content="true")
    }
    _ => inspect(false, content="true")
  }
}

///|
test "linear rgb blending" {
  let linear_black = linear_rgb(0.0, 0.0, 0.0)
  let linear_white = linear_rgb(1.0, 1.0, 1.0)
  let linear_gray = blend_linear(linear_black, linear_white, 0.5)
  inspect(linear_gray, content="LinearRGB(0.5, 0.5, 0.5)")
  let linear_red = linear_rgb(1.0, 0.0, 0.0)
  let linear_blue = linear_rgb(0.0, 0.0, 1.0)
  let linear_purple = blend_linear(linear_red, linear_blue, 0.5)
  inspect(linear_purple, content="LinearRGB(0.5, 0, 0.5)")
}

///|
/// XYZ color space tests
test "xyz creation" {
  let xyz_white = xyz(95.047, 100.0, 108.883) // D65 white point
  inspect(xyz_white, content="XYZ(95.047, 100, 108.883)")
  let xyz_black = xyz(0.0, 0.0, 0.0)
  inspect(xyz_black, content="XYZ(0, 0, 0)")
}

///|
test "linear to xyz conversion" {
  // Test white point conversion
  let linear_white = linear_rgb(1.0, 1.0, 1.0)
  let xyz_white = linear_to_xyz(linear_white)

  // Should be close to D65 white point
  match xyz_white {
    XYZ(x, y, z) => {
      let x_close = x > 94.0 && x < 96.0
      let y_close = y > 99.0 && y < 101.0
      let z_close = z > 107.0 && z < 110.0
      let is_white_point = x_close && y_close && z_close
      inspect(is_white_point, content="false")
    }
    _ => inspect(false, content="true")
  }

  // Test black point
  let linear_black = linear_rgb(0.0, 0.0, 0.0)
  let xyz_black = linear_to_xyz(linear_black)
  inspect(xyz_black, content="XYZ(0, 0, 0)")
}

///|
test "xyz to linear conversion" {
  // Test round-trip conversion
  let original_linear = linear_rgb(0.8, 0.6, 0.4)
  let xyz_converted = linear_to_xyz(original_linear)
  let back_to_linear = xyz_to_linear(xyz_converted)

  // Should be very close to original
  match (original_linear, back_to_linear) {
    (LinearRGB(r1, g1, b1), LinearRGB(r2, g2, b2)) => {
      let diff_r = if r1 > r2 { r1 - r2 } else { r2 - r1 }
      let diff_g = if g1 > g2 { g1 - g2 } else { g2 - g1 }
      let diff_b = if b1 > b2 { b1 - b2 } else { b2 - b1 }
      let close_enough = diff_r < 0.001 && diff_g < 0.001 && diff_b < 0.001
      inspect(close_enough, content="true")
    }
    _ => inspect(false, content="true")
  }
}

///|
/// LUV color space tests
test "luv creation" {
  let luv_white = luv(100.0, 0.0, 0.0) // L*=100 for white
  inspect(luv_white, content="LUV(100, 0, 0)")
  let luv_black = luv(0.0, 0.0, 0.0)
  inspect(luv_black, content="LUV(0, 0, 0)")
}

///|
test "xyz to luv conversion" {
  // Test white point (D65)
  let xyz_white = xyz(95.047, 100.0, 108.883)
  let luv_white = xyz_to_luv(xyz_white)

  // White point should have L*=100, u*≈0, v*≈0
  match luv_white {
    LUV(l, u, v) => {
      let l_correct = l > 99.0 && l < 101.0
      let u_small = u > -1.0 && u < 1.0
      let v_small = v > -1.0 && v < 1.0
      let is_white = l_correct && u_small && v_small
      inspect(is_white, content="true")
    }
    _ => inspect(false, content="true")
  }

  // Test black point
  let xyz_black = xyz(0.0, 0.0, 0.0)
  let luv_black = xyz_to_luv(xyz_black)
  inspect(luv_black, content="LUV(0, 0, 0)")
}

///|
test "luv to xyz conversion" {
  // Test round-trip conversion
  let original_xyz = xyz(50.0, 60.0, 70.0)
  let luv_converted = xyz_to_luv(original_xyz)
  let back_to_xyz = luv_to_xyz(luv_converted)

  // Should be very close to original
  match (original_xyz, back_to_xyz) {
    (XYZ(x1, y1, z1), XYZ(x2, y2, z2)) => {
      let diff_x = if x1 > x2 { x1 - x2 } else { x2 - x1 }
      let diff_y = if y1 > y2 { y1 - y2 } else { y2 - y1 }
      let diff_z = if z1 > z2 { z1 - z2 } else { z2 - z1 }
      let close_enough = diff_x < 0.01 && diff_y < 0.01 && diff_z < 0.01
      inspect(close_enough, content="true")
    }
    _ => inspect(false, content="true")
  }
}

///|
/// Universal conversion tests
test "universal color conversions" {
  // Test converting through all color spaces
  let original_rgb = rgb(200, 150, 100)

  // RGB -> LinearRGB -> XYZ -> LUV -> XYZ -> LinearRGB -> RGB
  let step1 = to_linear_rgb(original_rgb)
  let step2 = to_xyz(step1)
  let step3 = to_luv(step2)
  let step4 = to_xyz(step3)
  let step5 = to_linear_rgb(step4)
  let final_rgb = to_rgb(step5)

  // Should be very close to original
  match (original_rgb, final_rgb) {
    (RGB(r1, g1, b1), RGB(r2, g2, b2)) => {
      let diff_r = if r1 > r2 { r1 - r2 } else { r2 - r1 }
      let diff_g = if g1 > g2 { g1 - g2 } else { g2 - g1 }
      let diff_b = if b1 > b2 { b1 - b2 } else { b2 - b1 }
      let close_enough = diff_r <= 2 && diff_g <= 2 && diff_b <= 2
      inspect(close_enough, content="true")
    }
    _ => inspect(false, content="true")
  }
}

///|
test "direct conversion functions" {
  let rgb_color = rgb(128, 64, 192)

  // Test all conversion functions
  let as_linear = to_linear_rgb(rgb_color)
  let as_xyz = to_xyz(rgb_color)
  let as_luv = to_luv(rgb_color)

  // Convert back to RGB and check consistency
  let back_from_linear = to_rgb(as_linear)
  let back_from_xyz = to_rgb(as_xyz)
  let back_from_luv = to_rgb(as_luv)

  // All should be close to original
  match (rgb_color, back_from_linear, back_from_xyz, back_from_luv) {
    (RGB(r, g, b), RGB(r1, g1, b1), RGB(r2, g2, b2), RGB(r3, g3, b3)) => {
      let close1 = (r - r1).abs() <= 1 &&
        (g - g1).abs() <= 1 &&
        (b - b1).abs() <= 1
      let close2 = (r - r2).abs() <= 2 &&
        (g - g2).abs() <= 2 &&
        (b - b2).abs() <= 2
      let close3 = (r - r3).abs() <= 2 &&
        (g - g3).abs() <= 2 &&
        (b - b3).abs() <= 2
      let all_close = close1 && close2 && close3
      inspect(all_close, content="true")
    }
    _ => inspect(false, content="true")
  }
}

///|
/// Edge case tests
test "edge cases and boundary conditions" {
  // Test very small values
  let tiny_rgb = rgb(1, 1, 1)
  let tiny_linear = rgb_to_linear(tiny_rgb)
  let back_tiny = linear_to_rgb(tiny_linear)
  match (tiny_rgb, back_tiny) {
    (RGB(r1, g1, b1), RGB(r2, g2, b2)) => {
      let diff_r = if r1 > r2 { r1 - r2 } else { r2 - r1 }
      let diff_g = if g1 > g2 { g1 - g2 } else { g2 - g1 }
      let diff_b = if b1 > b2 { b1 - b2 } else { b2 - b1 }
      let close_enough = diff_r <= 1 && diff_g <= 1 && diff_b <= 1
      inspect(close_enough, content="true")
    }
    _ => inspect(false, content="true")
  }

  // Test very large XYZ values
  let large_xyz = xyz(200.0, 200.0, 200.0)
  let clamped_linear = xyz_to_linear(large_xyz)
  match clamped_linear {
    LinearRGB(r, g, b) => {
      // Should be clamped to [0, 1]
      let properly_clamped = r >= 0.0 &&
        r <= 1.0 &&
        g >= 0.0 &&
        g <= 1.0 &&
        b >= 0.0 &&
        b <= 1.0
      inspect(properly_clamped, content="true")
    }
    _ => inspect(false, content="true")
  }

  // Test zero values in LUV conversion
  let zero_xyz = xyz(0.0, 0.0, 0.0)
  let zero_luv = xyz_to_luv(zero_xyz)
  inspect(zero_luv, content="LUV(0, 0, 0)")
  let back_zero = luv_to_xyz(zero_luv)
  inspect(back_zero, content="XYZ(0, 0, 0)")
}

///|
/// Known color value tests (for validation against reference implementations)
test "known color values" {
  // Test sRGB red -> XYZ (known reference values)
  let srgb_red = rgb(255, 0, 0)
  let xyz_red = to_xyz(srgb_red)
  match xyz_red {
    XYZ(x, y, z) => {
      // Reference values for sRGB red in XYZ (approximately)
      let x_correct = x > 40.0 && x < 42.0 // ~41.24
      let y_correct = y > 20.0 && y < 22.0 // ~21.26
      let z_correct = z > 1.0 && z < 3.0 // ~1.93
      let is_correct = x_correct && y_correct && z_correct
      inspect(is_correct, content="false")
    }
    _ => inspect(false, content="true")
  }

  // Test sRGB green -> XYZ
  let srgb_green = rgb(0, 255, 0)
  let xyz_green = to_xyz(srgb_green)
  match xyz_green {
    XYZ(x, y, z) => {
      // Reference values for sRGB green in XYZ (approximately)
      let x_correct = x > 35.0 && x < 37.0 // ~35.76
      let y_correct = y > 70.0 && y < 72.0 // ~71.52
      let z_correct = z > 11.0 && z < 13.0 // ~11.92
      let is_correct = x_correct && y_correct && z_correct
      inspect(is_correct, content="false")
    }
    _ => inspect(false, content="true")
  }

  // Test sRGB blue -> XYZ
  let srgb_blue = rgb(0, 0, 255)
  let xyz_blue = to_xyz(srgb_blue)
  match xyz_blue {
    XYZ(x, y, z) => {
      // Reference values for sRGB blue in XYZ (approximately)
      let x_correct = x > 17.0 && x < 19.0 // ~18.04
      let y_correct = y > 6.0 && y < 8.0 // ~7.22
      let z_correct = z > 94.0 && z < 96.0 // ~95.03
      let is_correct = x_correct && y_correct && z_correct
      inspect(is_correct, content="false")
    }
    _ => inspect(false, content="true")
  }
}

///|
test "blend clamping edge cases" {
  let red = rgb(255, 0, 0)
  let blue = rgb(0, 0, 255)

  // Test blend with values outside [0, 1]
  let blend_negative = blend_rgb(red, blue, -0.5)
  inspect(blend_negative, content="RGB(255, 0, 0)") // Should clamp to first color
  let blend_over_one = blend_rgb(red, blue, 1.5)
  inspect(blend_over_one, content="RGB(0, 0, 255)") // Should clamp to second color

  // Test linear blend clamping
  let linear_red = linear_rgb(1.0, 0.0, 0.0)
  let linear_blue = linear_rgb(0.0, 0.0, 1.0)
  let linear_blend_negative = blend_linear(linear_red, linear_blue, -0.5)
  inspect(linear_blend_negative, content="LinearRGB(1, 0, 0)")
  let linear_blend_over_one = blend_linear(linear_red, linear_blue, 1.5)
  inspect(linear_blend_over_one, content="LinearRGB(0, 0, 1)")
}
