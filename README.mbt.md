# Colors Library

A comprehensive MoonBit library for manipulating colors across multiple color spaces with proper gamma correction and type safety.

This library is a port of the [OCaml colors library](https://github.com/ocaml-tui/colors) to MoonBit, redesigned with an object-oriented API using MoonBit's `fn Type::method` syntax.

## Features

- **Multiple Color Spaces**: RGB, LinearRGB, XYZ, and CIE LUV
- **Seamless Conversions**: Convert between any color spaces with automatic intermediate conversions
- **Color Blending**: Blend colors in RGB or LinearRGB space with proper gamma handling
- **Gamma Correction**: Proper sRGB gamma correction for accurate color representation
- **Type Safety**: Full type safety with MoonBit's type system and runtime checks
- **Object-Oriented API**: Clean, discoverable API using static and instance methods
- **Method Chaining**: Fluent API for chaining color operations

## Quick Start

```moonbit
// Create colors using constructor methods
let red : Color = @colors.Color::rgb(255, 0, 0)
let linear_red : Color = @colors.Color::linear_rgb(1.0, 0.0, 0.0)

// Convert between color spaces
let xyz_red : Color = red.as_xyz()
let luv_red : Color = red.as_luv()

// Chain conversions
let final_color : Color = red.to_linear().to_xyz().to_luv().as_rgb()

// Blend colors
let blue : Color = @colors.Color::rgb(0, 0, 255)
let purple : Color = @colors.Color::blend_rgb(red, blue, 0.5)
```

## Documentation

- **[API Reference](API.md)**: Complete API documentation with examples
- **[Usage Examples](#usage-examples)**: Common usage patterns below
- **[Color Space Guide](API.md#color-space-information)**: Detailed information about each color space

## Usage Examples

### Creating Colors

test "creating colors in different color spaces" {
  // Create RGB colors (0-255 range)
  let red = @colors.Color::rgb(255, 0, 0)
  let green = @colors.Color::rgb(0, 255, 0)
  let blue = @colors.Color::rgb(0, 0, 255)
  let white = @colors.Color::rgb(255, 255, 255)
  
  inspect(red, content="RGB(255, 0, 0)")
  inspect(white, content="RGB(255, 255, 255)")
  
  // Create LinearRGB colors (0.0-1.0 range)
  let linear_red = @colors.Color::linear_rgb(1.0, 0.0, 0.0)
  let linear_gray = @colors.Color::linear_rgb(0.5, 0.5, 0.5)
  
  inspect(linear_red, content="LinearRGB(1, 0, 0)")
  inspect(linear_gray, content="LinearRGB(0.5, 0.5, 0.5)")
  
  // Create XYZ colors (D65 white point)
  let xyz_white = @colors.Color::xyz(95.047, 100.0, 108.883)
  inspect(xyz_white, content="XYZ(95.047, 100, 108.883)")
  
  // Create LUV colors
  let luv_white = @colors.Color::luv(100.0, 0.0, 0.0)
  inspect(luv_white, content="LUV(100, 0, 0)")
}

### Color Space Conversions

test "converting between color spaces" {
  // Start with an RGB color
  let rgb_color = @colors.Color::rgb(200, 150, 100)
  
  // Convert through different color spaces
  let as_linear = rgb_color.as_linear_rgb()
  let as_xyz = rgb_color.as_xyz()
  let as_luv = rgb_color.as_luv()
  
  // Convert back to RGB to verify round-trip accuracy
  let back_from_linear = as_linear.as_rgb()
  let back_from_xyz = as_xyz.as_rgb()
  let back_from_luv = as_luv.as_rgb()
  
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
  let black = @colors.Color::rgb(0, 0, 0)
  let white = @colors.Color::rgb(255, 255, 255)
  let red = @colors.Color::rgb(255, 0, 0)
  let blue = @colors.Color::rgb(0, 0, 255)
  
  // 50% blend creates gray
  let gray = @colors.Color::blend_rgb(black, white, 0.5)
  inspect(gray, content="RGB(128, 128, 128)")
  
  // 25% blend is closer to first color
  let dark_gray = @colors.Color::blend_rgb(black, white, 0.25)
  inspect(dark_gray, content="RGB(64, 64, 64)")
  
  // Blend red and blue to create purple
  let purple = @colors.Color::blend_rgb(red, blue, 0.5)
  inspect(purple, content="RGB(128, 0, 128)")
  
  // Linear RGB blending (more accurate for lighting)
  let linear_red = @colors.Color::linear_rgb(1.0, 0.0, 0.0)
  let linear_blue = @colors.Color::linear_rgb(0.0, 0.0, 1.0)
  let linear_purple = @colors.Color::blend_linear(linear_red, linear_blue, 0.5)
  inspect(linear_purple, content="LinearRGB(0.5, 0, 0.5)")
}

### Gamma Correction

test "gamma correction demonstration" {
  // RGB 128 is not 50% brightness due to gamma correction
  let rgb_mid = @colors.Color::rgb(128, 128, 128)
  let linear_mid = rgb_mid.to_linear()
  
  match linear_mid {
    LinearRGB(r, _, _) => {
      // Linear value should be around 0.22, not 0.5
      let is_gamma_corrected = r < 0.3 && r > 0.1
      inspect(is_gamma_corrected, content="true")
    }
    _ => inspect(false, content="true")
  }
  
  // Convert back should give original value
  let back_to_rgb = linear_mid.from_linear()
  inspect(back_to_rgb, content="RGB(128, 128, 128)")
}

### Working with Standard Colors

test "standard color operations" {
  // Create primary colors
  let red = @colors.Color::rgb(255, 0, 0)
  let green = @colors.Color::rgb(0, 255, 0) 
  let blue = @colors.Color::rgb(0, 0, 255)
  
  // Mix primaries to get secondaries
  let yellow = @colors.Color::blend_rgb(red, green, 0.5)
  let cyan = @colors.Color::blend_rgb(green, blue, 0.5)
  let magenta = @colors.Color::blend_rgb(red, blue, 0.5)
  
  inspect(yellow, content="RGB(128, 128, 0)")
  inspect(cyan, content="RGB(0, 128, 128)")
  inspect(magenta, content="RGB(128, 0, 128)")
  
  // Convert to XYZ for color science applications
  let red_xyz = red.as_xyz()
  match red_xyz {
    XYZ(x, y, z) => {
      // Red should have high X, low Y, very low Z
      let is_red_xyz = x > 40.0 && y > 20.0 && z < 5.0
      inspect(is_red_xyz, content="true")
    }
    _ => inspect(false, content="true")
  }
}

## API Design

This library uses MoonBit's object-oriented features to provide a clean, discoverable API:

### Constructor Methods (Static)
```moonbit
let red : Color = @colors.Color::rgb(255, 0, 0)        // Create RGB color
let linear : Color = @colors.Color::linear_rgb(1.0, 0.0, 0.0)  // Create LinearRGB color
let xyz : Color = @colors.Color::xyz(41.24, 21.26, 1.93)    // Create XYZ color
let luv : Color = @colors.Color::luv(53.24, 175.05, 37.75)  // Create LUV color
```

### Instance Methods (Conversions)
```moonbit
let linear_color : Color = color.to_linear()      // RGB → LinearRGB
let rgb_color : Color = color.from_linear()    // LinearRGB → RGB
let xyz_color : Color = color.to_xyz()         // LinearRGB → XYZ
let linear_from_xyz : Color = color.from_xyz()       // XYZ → LinearRGB
let luv_color : Color = color.to_luv()         // XYZ → LUV
let xyz_from_luv : Color = color.from_luv()       // LUV → XYZ
```

### Universal Conversions (Instance)
```moonbit
let rgb : Color = color.as_rgb()         // Any color space → RGB
let linear : Color = color.as_linear_rgb()  // Any color space → LinearRGB
let xyz : Color = color.as_xyz()         // Any color space → XYZ
let luv : Color = color.as_luv()         // Any color space → LUV
```

### Blending Methods (Static)
```moonbit
let blended_rgb : Color = @colors.Color::blend_rgb(color1, color2, 0.5)     // Blend RGB colors
let blended_linear : Color = @colors.Color::blend_linear(color1, color2, 0.5)  // Blend LinearRGB colors
```

## Installation

Add this library to your MoonBit project:

```json
{
  "deps": {
    "bobzhang/colors": "*"
  }
}
```

## Testing

Run the comprehensive test suite:

```bash
moon test
```

The library includes 17 test cases covering all color spaces, conversions, edge cases, and known reference values.

## Contributing

Contributions are welcome! Please ensure all tests pass and add tests for new functionality.

## License

This project is licensed under the same terms as the original OCaml colors library.