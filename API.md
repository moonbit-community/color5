# Colors Library API Reference

A comprehensive MoonBit library for color manipulation across multiple color spaces with proper gamma correction and type safety.

## Table of Contents

- [Color Type](#color-type)
- [Constructor Methods](#constructor-methods)
- [Conversion Methods](#conversion-methods)
- [Universal Conversion Methods](#universal-conversion-methods)
- [Blending Methods](#blending-methods)
- [Usage Examples](#usage-examples)
- [Color Space Information](#color-space-information)

## Color Type

The library defines a single `Color` enum that represents colors in different color spaces:

```moonbit
pub enum Color {
  RGB(Int, Int, Int)                    // Standard RGB (0-255)
  LinearRGB(Double, Double, Double)     // Linear RGB (0.0-1.0)
  XYZ(Double, Double, Double)           // CIE XYZ color space
  LUV(Double, Double, Double)           // CIE LUV color space
} derive(Show)
```

## Constructor Methods

All constructor methods are static methods on the `Color` type.

### `Color::rgb(r: Int, g: Int, b: Int) -> Color`

Creates an RGB color from 8-bit values (0-255). Values are automatically clamped to the valid range.

```moonbit
let red = @colors.Color::rgb(255, 0, 0)
let green = @colors.Color::rgb(0, 255, 0)
let blue = @colors.Color::rgb(0, 0, 255)
let white = @colors.Color::rgb(255, 255, 255)
let black = @colors.Color::rgb(0, 0, 0)

// Values are automatically clamped
let clamped = @colors.Color::rgb(300, -50, 128)  // becomes RGB(255, 0, 128)
```

### `Color::linear_rgb(r: Double, g: Double, b: Double) -> Color`

Creates a LinearRGB color from normalized values (0.0-1.0). Values are automatically clamped to the valid range.

```moonbit
let linear_red = @colors.Color::linear_rgb(1.0, 0.0, 0.0)
let linear_gray = @colors.Color::linear_rgb(0.5, 0.5, 0.5)
let linear_white = @colors.Color::linear_rgb(1.0, 1.0, 1.0)

// Values are automatically clamped
let clamped = @colors.Color::linear_rgb(2.0, -0.5, 0.8)  // becomes LinearRGB(1.0, 0.0, 0.8)
```

### `Color::xyz(x: Double, y: Double, z: Double) -> Color`

Creates an XYZ color in the CIE XYZ color space.

```moonbit
// D65 white point
let xyz_white = @colors.Color::xyz(95.047, 100.0, 108.883)
let xyz_black = @colors.Color::xyz(0.0, 0.0, 0.0)
let xyz_custom = @colors.Color::xyz(50.0, 60.0, 70.0)
```

### `Color::luv(l: Double, u: Double, v: Double) -> Color`

Creates a LUV color in the CIE LUV color space.

```moonbit
// L*=100 for white, L*=0 for black
let luv_white = @colors.Color::luv(100.0, 0.0, 0.0)
let luv_black = @colors.Color::luv(0.0, 0.0, 0.0)
let luv_custom = @colors.Color::luv(50.0, 25.0, -15.0)
```

## Conversion Methods

These are instance methods that convert between specific color spaces.

### RGB ↔ LinearRGB Conversions

#### `to_linear(self: Color) -> Color`

Converts RGB to LinearRGB with proper gamma correction.

```moonbit
let rgb_color = @colors.Color::rgb(128, 128, 128)
let linear_color = rgb_color.to_linear()
// RGB(128, 128, 128) becomes approximately LinearRGB(0.22, 0.22, 0.22)
// Note: Not 0.5 due to gamma correction!
```

#### `from_linear(self: Color) -> Color`

Converts LinearRGB to RGB with proper gamma correction.

```moonbit
let linear_color = @colors.Color::linear_rgb(0.5, 0.5, 0.5)
let rgb_color = linear_color.from_linear()
// LinearRGB(0.5, 0.5, 0.5) becomes approximately RGB(188, 188, 188)
```

### LinearRGB ↔ XYZ Conversions

#### `to_xyz(self: Color) -> Color`

Converts LinearRGB to XYZ color space.

```moonbit
let linear_white = @colors.Color::linear_rgb(1.0, 1.0, 1.0)
let xyz_white = linear_white.to_xyz()
// Should be close to D65 white point: XYZ(95.047, 100.0, 108.883)
```

#### `from_xyz(self: Color) -> Color`

Converts XYZ to LinearRGB color space. Values are clamped to [0.0, 1.0].

```moonbit
let xyz_color = @colors.Color::xyz(50.0, 60.0, 70.0)
let linear_color = xyz_color.from_xyz()
// Converts to LinearRGB with clamped values
```

### XYZ ↔ LUV Conversions

#### `to_luv(self: Color) -> Color`

Converts XYZ to LUV color space using D65 white point.

```moonbit
let xyz_white = @colors.Color::xyz(95.047, 100.0, 108.883)
let luv_white = xyz_white.to_luv()
// D65 white point becomes LUV(100.0, ~0.0, ~0.0)
```

#### `from_luv(self: Color) -> Color`

Converts LUV to XYZ color space using D65 white point.

```moonbit
let luv_color = @colors.Color::luv(50.0, 25.0, -15.0)
let xyz_color = luv_color.from_luv()
// Converts back to XYZ color space
```

## Universal Conversion Methods

These instance methods can convert from any color space to any other color space.

### `as_rgb(self: Color) -> Color`

Converts any color to RGB, performing all necessary intermediate conversions.

```moonbit
let xyz_color = @colors.Color::xyz(41.24, 21.26, 1.93)
let rgb_color = xyz_color.as_rgb()  // Converts XYZ → LinearRGB → RGB

let luv_color = @colors.Color::luv(53.24, 175.05, 37.75)
let rgb_from_luv = luv_color.as_rgb()  // Converts LUV → XYZ → LinearRGB → RGB
```

### `as_linear_rgb(self: Color) -> Color`

Converts any color to LinearRGB.

```moonbit
let rgb_color = @colors.Color::rgb(255, 0, 0)
let linear_color = rgb_color.as_linear_rgb()  // Converts RGB → LinearRGB

let luv_color = @colors.Color::luv(53.24, 175.05, 37.75)
let linear_from_luv = luv_color.as_linear_rgb()  // Converts LUV → XYZ → LinearRGB
```

### `as_xyz(self: Color) -> Color`

Converts any color to XYZ.

```moonbit
let rgb_color = @colors.Color::rgb(255, 0, 0)
let xyz_color = rgb_color.as_xyz()  // Converts RGB → LinearRGB → XYZ

let luv_color = @colors.Color::luv(53.24, 175.05, 37.75)
let xyz_from_luv = luv_color.as_xyz()  // Converts LUV → XYZ
```

### `as_luv(self: Color) -> Color`

Converts any color to LUV.

```moonbit
let rgb_color = @colors.Color::rgb(255, 0, 0)
let luv_color = rgb_color.as_luv()  // Converts RGB → LinearRGB → XYZ → LUV

let linear_color = @colors.Color::linear_rgb(1.0, 0.0, 0.0)
let luv_from_linear = linear_color.as_luv()  // Converts LinearRGB → XYZ → LUV
```

## Blending Methods

Static methods for blending colors. Both colors must be in the same color space.

### `Color::blend_rgb(color1: Color, color2: Color, mix: Double) -> Color`

Blends two RGB colors. The `mix` parameter controls the blend ratio:
- `0.0` = 100% first color
- `0.5` = 50/50 blend
- `1.0` = 100% second color

Values outside [0.0, 1.0] are automatically clamped.

```moonbit
let red = @colors.Color::rgb(255, 0, 0)
let blue = @colors.Color::rgb(0, 0, 255)

let purple = @colors.Color::blend_rgb(red, blue, 0.5)
// Result: RGB(128, 0, 128)

let mostly_red = @colors.Color::blend_rgb(red, blue, 0.25)
// Result: RGB(192, 0, 64)

let mostly_blue = @colors.Color::blend_rgb(red, blue, 0.75)
// Result: RGB(64, 0, 192)
```

### `Color::blend_linear(color1: Color, color2: Color, mix: Double) -> Color`

Blends two LinearRGB colors. This is more accurate for lighting calculations as it operates in linear space.

```moonbit
let linear_red = @colors.Color::linear_rgb(1.0, 0.0, 0.0)
let linear_blue = @colors.Color::linear_rgb(0.0, 0.0, 1.0)

let linear_purple = @colors.Color::blend_linear(linear_red, linear_blue, 0.5)
// Result: LinearRGB(0.5, 0.0, 0.5)
```

## Usage Examples

### Basic Color Creation and Conversion

```moonbit
// Create colors in different spaces
let rgb_red = @colors.Color::rgb(255, 0, 0)
let linear_red = @colors.Color::linear_rgb(1.0, 0.0, 0.0)
let xyz_red = @colors.Color::xyz(41.24, 21.26, 1.93)
let luv_red = @colors.Color::luv(53.24, 175.05, 37.75)

// Convert between specific color spaces
let rgb_to_linear = rgb_red.to_linear()
let linear_to_xyz = linear_red.to_xyz()
let xyz_to_luv = xyz_red.to_luv()

// Universal conversions (work from any color space)
let any_to_rgb = xyz_red.as_rgb()
let any_to_linear = luv_red.as_linear_rgb()
let any_to_xyz = rgb_red.as_xyz()
let any_to_luv = linear_red.as_luv()
```

### Method Chaining

```moonbit
let rgb_color = @colors.Color::rgb(200, 150, 100)

// Chain conversions through multiple color spaces
let final_color = rgb_color
  .as_linear_rgb()
  .as_xyz()
  .as_luv()
  .as_rgb()

// Should be very close to the original color
```

### Color Blending

```moonbit
// RGB blending
let black = @colors.Color::rgb(0, 0, 0)
let white = @colors.Color::rgb(255, 255, 255)
let gray = @colors.Color::blend_rgb(black, white, 0.5)  // RGB(128, 128, 128)

// Create color gradients
let red = @colors.Color::rgb(255, 0, 0)
let yellow = @colors.Color::rgb(255, 255, 0)
let orange = @colors.Color::blend_rgb(red, yellow, 0.5)  // RGB(255, 128, 0)

// Linear blending (more accurate for lighting)
let linear_red = @colors.Color::linear_rgb(1.0, 0.0, 0.0)
let linear_green = @colors.Color::linear_rgb(0.0, 1.0, 0.0)
let linear_blend = @colors.Color::blend_linear(linear_red, linear_green, 0.3)
```

### Gamma Correction Demonstration

```moonbit
// Demonstrates the difference between RGB and LinearRGB
let rgb_mid = @colors.Color::rgb(128, 128, 128)  // 50% in RGB space
let linear_mid = rgb_mid.to_linear()

// The linear value will be around 0.22, not 0.5!
// This is because RGB uses gamma encoding
match linear_mid {
  LinearRGB(r, g, b) => {
    // r ≈ 0.22, not 0.5
    println("RGB 128 = Linear {r}")
  }
  _ => ()
}

// Convert back to verify round-trip accuracy
let back_to_rgb = linear_mid.from_linear()  // Should be RGB(128, 128, 128)
```

### Working with Standard Colors

```moonbit
// Primary colors
let red = @colors.Color::rgb(255, 0, 0)
let green = @colors.Color::rgb(0, 255, 0)
let blue = @colors.Color::rgb(0, 0, 255)

// Secondary colors through blending
let cyan = @colors.Color::blend_rgb(green, blue, 0.5)     // RGB(0, 128, 128)
let magenta = @colors.Color::blend_rgb(red, blue, 0.5)    // RGB(128, 0, 128)
let yellow = @colors.Color::blend_rgb(red, green, 0.5)    // RGB(128, 128, 0)

// Convert to XYZ for color science applications
let red_xyz = red.as_xyz()
match red_xyz {
  XYZ(x, y, z) => {
    println("Red in XYZ: X={x}, Y={y}, Z={z}")
    // Should be approximately: X≈41.24, Y≈21.26, Z≈1.93
  }
  _ => ()
}
```

## Color Space Information

### RGB (0-255)
- **Range**: R, G, B ∈ [0, 255] (integers)
- **Gamma**: sRGB gamma encoding (~2.2)
- **Use**: Display, web colors, user interfaces
- **Note**: Values are automatically clamped to valid range

### LinearRGB (0.0-1.0)
- **Range**: R, G, B ∈ [0.0, 1.0] (doubles)
- **Gamma**: Linear (no gamma encoding)
- **Use**: Lighting calculations, physically accurate blending
- **Note**: Values are automatically clamped to valid range

### XYZ
- **Range**: X, Y, Z ∈ [0.0, ∞) (doubles, but typically 0-100)
- **White Point**: D65 (95.047, 100.0, 108.883)
- **Use**: Color science, device-independent color
- **Note**: Intermediate space for most conversions

### LUV
- **Range**: L* ∈ [0, 100], u*, v* ∈ [-∞, ∞] (doubles)
- **White Point**: D65
- **Use**: Perceptually uniform color space
- **Note**: L* represents lightness, u* and v* represent chromaticity

## Error Handling

The library uses `abort()` for type mismatches in conversion functions. This ensures type safety at runtime:

```moonbit
// This will abort if color is not RGB
let linear = rgb_color.to_linear()  // OK if rgb_color is RGB

// Universal conversions work with any color type
let rgb = any_color.as_rgb()  // Always works, regardless of input type
```

## Performance Notes

- All conversions are computed on-demand
- No caching is performed
- Round-trip conversions may have small floating-point errors
- RGB ↔ LinearRGB conversions are the fastest
- LUV conversions are the most computationally expensive

## Thread Safety

All functions are pure and thread-safe. The library maintains no global state.
