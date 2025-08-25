# Colors Library

A pure MoonBit library for manipulating colors in different color spaces.

This library is a port of the [OCaml colors library](https://github.com/ocaml-tui/colors) to MoonBit.

## Features

- Multiple Color Spaces: RGB, LinearRGB, XYZ, and CIE LUV
- Seamless Conversions between all color spaces
- Color Blending functionality
- Proper sRGB gamma correction
- Type Safety with MoonBit's type system

## Usage Examples

### Creating Colors

test "creating colors in different color spaces" {
  // Create RGB colors (0-255 range)
  let red = @colors.rgb(166, 255, 0)
  let green = @colors.rgb(0, 255, 0)
  let blue = @colors.rgb(0, 0, 255)
  let white = @colors.rgb(255, 255, 255)
  
  inspect(red, content="RGB(255, 0, 0)")
  inspect(white, content="RGB(255, 255, 255)")
  
  // Create LinearRGB colors (0.0-1.0 range)
  let linear_red = @colors.linear_rgb(1.0, 0.0, 0.0)
  let linear_gray = @colors.linear_rgb(0.5, 0.5, 0.5)
  
  inspect(linear_red, content="LinearRGB(1, 0, 0)")
  inspect(linear_gray, content="LinearRGB(0.5, 0.5, 0.5)")
  
  // Create XYZ colors (D65 white point)
  let xyz_white = @colors.xyz(95.047, 100.0, 108.883)
  inspect(xyz_white, content="XYZ(95.047, 100, 108.883)")
  
  // Create LUV colors
  let luv_white = @colors.luv(100.0, 0.0, 0.0)
  inspect(luv_white, content="LUV(100, 0, 0)")
}

### Color Space Conversions

test "converting between color spaces" {
  // Start with an RGB color
  let rgb_color = @colors.rgb(200, 150, 100)
  
  // Convert through different color spaces
  let as_linear = @colors.to_linear_rgb(rgb_color)
  let as_xyz = @colors.to_xyz(rgb_color)
  let as_luv = @colors.to_luv(rgb_color)
  
  // Convert back to RGB to verify round-trip accuracy
  let back_from_linear = @colors.to_rgb(as_linear)
  let back_from_xyz = @colors.to_rgb(as_xyz)
  let back_from_luv = @colors.to_rgb(as_luv)
  
  // All conversions should be very close to the original
  inspect(rgb_color, content="RGB(200, 150, 100)")
  inspect(back_from_linear, content="RGB(200, 150, 100)")
  
  // XYZ and LUV conversions may have small rounding differences
  match (rgb_color, back_from_xyz) {
    (RGB(r1, g1, b1), RGB(r2, g2, b2)) => {
      let close = (r1 - r2).abs() <= 2 && (g1 - g2).abs() <= 2 && (b1 - b2).abs() <= 2
      inspect(close, content="true")
    }
    _ => inspect(false, content="true")
  }
}

### Color Blending

test "blending colors" {
  let black = @colors.rgb(0, 0, 0)
  let white = @colors.rgb(255, 255, 255)
  let red = @colors.rgb(255, 0, 0)
  let blue = @colors.rgb(0, 0, 255)
  
  // 50% blend creates gray
  let gray = @colors.blend_rgb(black, white, 0.5)
  inspect(gray, content="RGB(128, 128, 128)")
  
  // 25% blend is closer to first color
  let dark_gray = @colors.blend_rgb(black, white, 0.25)
  inspect(dark_gray, content="RGB(64, 64, 64)")
  
  // Blend red and blue to create purple
  let purple = @colors.blend_rgb(red, blue, 0.5)
  inspect(purple, content="RGB(128, 0, 128)")
  
  // Linear RGB blending (more accurate for lighting)
  let linear_red = @colors.linear_rgb(1.0, 0.0, 0.0)
  let linear_blue = @colors.linear_rgb(0.0, 0.0, 1.0)
  let linear_purple = @colors.blend_linear(linear_red, linear_blue, 0.5)
  inspect(linear_purple, content="LinearRGB(0.5, 0, 0.5)")
}

### Gamma Correction

test "gamma correction demonstration" {
  // RGB 128 is not 50% brightness due to gamma correction
  let rgb_mid = @colors.rgb(128, 128, 128)
  let linear_mid = @colors.rgb_to_linear(rgb_mid)
  
  match linear_mid {
    LinearRGB(r, _, _) => {
      // Linear value should be around 0.22, not 0.5
      let is_gamma_corrected = r < 0.3 && r > 0.1
      inspect(is_gamma_corrected, content="true")
    }
    _ => inspect(false, content="true")
  }
  
  // Convert back should give original value
  let back_to_rgb = @colors.linear_to_rgb(linear_mid)
  inspect(back_to_rgb, content="RGB(128, 128, 128)")
}

### Working with Standard Colors

test "standard color operations" {
  // Create primary colors
  let red = @colors.rgb(255, 0, 0)
  let green = @colors.rgb(0, 255, 0) 
  let blue = @colors.rgb(0, 0, 255)
  
  // Mix primaries to get secondaries
  let yellow = @colors.blend_rgb(red, green, 0.5)
  let cyan = @colors.blend_rgb(green, blue, 0.5)
  let magenta = @colors.blend_rgb(red, blue, 0.5)
  
  inspect(yellow, content="RGB(128, 128, 0)")
  inspect(cyan, content="RGB(0, 128, 128)")
  inspect(magenta, content="RGB(128, 0, 128)")
  
  // Convert to XYZ for color science applications
  let red_xyz = @colors.to_xyz(red)
  match red_xyz {
    XYZ(x, y, z) => {
      // Red should have high X, low Y, very low Z
      let is_red_xyz = x > 40.0 && y > 20.0 && z < 5.0
      inspect(is_red_xyz, content="true")
    }
    _ => inspect(false, content="true")
  }
}

## Documentation

See the main README.md file for detailed technical documentation, API reference, and advanced usage examples.