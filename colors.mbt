///| Color type definitions and core functionality
/// A comprehensive MoonBit library for manipulating colors in different color spaces
/// with proper gamma correction and type safety.
///
/// This library provides an object-oriented API for working with colors across
/// multiple color spaces: RGB, LinearRGB, XYZ, and CIE LUV.

///|
/// Color type representing different color spaces.
///
/// # Color Spaces
/// - `RGB(r, g, b)`: Standard sRGB with gamma encoding, values 0-255
/// - `LinearRGB(r, g, b)`: Linear RGB without gamma encoding, values 0.0-1.0  
/// - `XYZ(x, y, z)`: CIE XYZ color space, device-independent
/// - `LUV(l, u, v)`: CIE LUV color space, perceptually uniform
///
/// # Example
/// ```moonbit
/// // Use constructor methods to create colors
/// let red_rgb = @colors.Color::rgb(255, 0, 0)
/// let red_linear = @colors.Color::linear_rgb(1.0, 0.0, 0.0)
/// 
/// inspect(red_rgb, content="RGB(255, 0, 0)")
/// inspect(red_linear, content="LinearRGB(1, 0, 0)")
/// ```
pub enum Color {
  RGB(Int, Int, Int) // Standard RGB (0-255)
  LinearRGB(Double, Double, Double) // Linear RGB (0.0-1.0)
  XYZ(Double, Double, Double) // CIE XYZ color space
  LUV(Double, Double, Double) // CIE LUV color space
} derive(Show)

///|
/// Constants for color space conversions
let srgb_to_xyz_matrix : Array[Array[Double]] = [
  [0.4124564, 0.3575761, 0.1804375],
  [0.2126729, 0.7151522, 0.0721750],
  [0.0193339, 0.1191920, 0.9503041],
]

///|
let xyz_to_srgb_matrix : Array[Array[Double]] = [
  [3.2404542, -1.5371385, -0.4985314],
  [-0.9692660, 1.8760108, 0.0415560],
  [0.0556434, -0.2040259, 1.0572252],
]

///|
/// D65 white point for LUV calculations
let white_point_d65 : (Double, Double, Double) = (95.047, 100.000, 108.883)

///| Utility functions for gamma correction and color space math

///|
/// Convert sRGB component to linear RGB
fn srgb_to_linear(component : Double) -> Double {
  if component <= 0.04045 {
    component / 12.92
  } else {
    ((component + 0.055) / 1.055).pow(2.4)
  }
}

///|
/// Convert linear RGB component to sRGB
fn linear_to_srgb(component : Double) -> Double {
  if component <= 0.0031308 {
    component * 12.92
  } else {
    1.055 * component.pow(1.0 / 2.4) - 0.055
  }
}

///|
/// Clamp value between min and max
fn clamp(value : Double, min : Double, max : Double) -> Double {
  if value < min {
    min
  } else if value > max {
    max
  } else {
    value
  }
}

///|
/// Matrix multiplication for 3x3 matrix and 3D vector
fn matrix_multiply(
  matrix : Array[Array[Double]],
  vector : (Double, Double, Double),
) -> (Double, Double, Double) {
  let (x, y, z) = vector
  let r = matrix[0][0] * x + matrix[0][1] * y + matrix[0][2] * z
  let g = matrix[1][0] * x + matrix[1][1] * y + matrix[1][2] * z
  let b = matrix[2][0] * x + matrix[2][1] * y + matrix[2][2] * z
  (r, g, b)
}

///| RGB color space functions

///|
/// Create an RGB color from 8-bit values (0-255).
///
/// Values are automatically clamped to the valid range [0, 255].
/// This creates a color in the standard sRGB color space with gamma encoding.
///
/// # Parameters
/// - `r`: Red component (0-255)
/// - `g`: Green component (0-255)  
/// - `b`: Blue component (0-255)
///
/// # Returns
/// A new `Color` in RGB color space
///
/// # Example
/// ```moonbit
/// let red = @colors.Color::rgb(255, 0, 0)
/// let clamped = @colors.Color::rgb(300, -50, 128)  // becomes RGB(255, 0, 128)
/// 
/// inspect(red, content="RGB(255, 0, 0)")
/// inspect(clamped, content="RGB(255, 0, 128)")
/// ```
pub fn Color::rgb(r : Int, g : Int, b : Int) -> Color {
  let r_clamped = if r < 0 { 0 } else if r > 255 { 255 } else { r }
  let g_clamped = if g < 0 { 0 } else if g > 255 { 255 } else { g }
  let b_clamped = if b < 0 { 0 } else if b > 255 { 255 } else { b }
  RGB(r_clamped, g_clamped, b_clamped)
}

///|
/// Convert RGB to LinearRGB with proper gamma correction.
///
/// This method applies the inverse sRGB gamma function to convert from
/// gamma-encoded RGB values to linear RGB values. This is essential for
/// accurate color calculations and blending.
///
/// # Parameters
/// - `self`: Must be an RGB color
///
/// # Returns
/// A new `Color` in LinearRGB color space
///
/// # Panics
/// Aborts if the color is not in RGB color space
///
/// # Example
/// ```moonbit
/// let rgb_gray = @colors.Color::rgb(128, 128, 128)
/// let linear_gray = rgb_gray.to_linear()
/// // RGB(128, 128, 128) becomes approximately LinearRGB(0.22, 0.22, 0.22)
/// // Note: Not 0.5 due to gamma correction!
/// 
/// inspect(rgb_gray, content="RGB(128, 128, 128)")
/// match linear_gray {
///   LinearRGB(r, _, _) => {
///     let is_gamma_corrected = r < 0.3 && r > 0.1
///     inspect(is_gamma_corrected, content="true")
///   }
///   _ => ()
/// }
/// ```
pub fn Color::to_linear(self : Color) -> Color {
  match self {
    RGB(r, g, b) => {
      let r_norm = r.to_double() / 255.0
      let g_norm = g.to_double() / 255.0
      let b_norm = b.to_double() / 255.0
      LinearRGB(
        srgb_to_linear(r_norm),
        srgb_to_linear(g_norm),
        srgb_to_linear(b_norm),
      )
    }
    _ => abort("Expected RGB color")
  }
}

///|
/// Convert LinearRGB to RGB  
pub fn Color::from_linear(self : Color) -> Color {
  match self {
    LinearRGB(r, g, b) => {
      let r_srgb = linear_to_srgb(r)
      let g_srgb = linear_to_srgb(g)
      let b_srgb = linear_to_srgb(b)
      let r_int = (clamp(r_srgb, 0.0, 1.0) * 255.0 + 0.5).to_int()
      let g_int = (clamp(g_srgb, 0.0, 1.0) * 255.0 + 0.5).to_int()
      let b_int = (clamp(b_srgb, 0.0, 1.0) * 255.0 + 0.5).to_int()
      RGB(r_int, g_int, b_int)
    }
    _ => abort("Expected LinearRGB color")
  }
}

///| LinearRGB color space functions

///|
/// Create a LinearRGB color from normalized values (0.0-1.0).
///
/// Values are automatically clamped to the valid range [0.0, 1.0].
/// This creates a color in linear RGB space without gamma encoding,
/// which is ideal for lighting calculations and physically accurate blending.
///
/// # Parameters
/// - `r`: Red component (0.0-1.0)
/// - `g`: Green component (0.0-1.0)
/// - `b`: Blue component (0.0-1.0)
///
/// # Returns
/// A new `Color` in LinearRGB color space
///
/// # Example
/// ```moonbit
/// let linear_red = @colors.Color::linear_rgb(1.0, 0.0, 0.0)
/// let clamped = @colors.Color::linear_rgb(2.0, -0.5, 0.8)  // becomes LinearRGB(1.0, 0.0, 0.8)
/// 
/// inspect(linear_red, content="LinearRGB(1, 0, 0)")
/// inspect(clamped, content="LinearRGB(1, 0, 0.8)")
/// ```
pub fn Color::linear_rgb(r : Double, g : Double, b : Double) -> Color {
  LinearRGB(clamp(r, 0.0, 1.0), clamp(g, 0.0, 1.0), clamp(b, 0.0, 1.0))
}

///|
/// Convert LinearRGB to XYZ
pub fn Color::to_xyz(self : Color) -> Color {
  match self {
    LinearRGB(r, g, b) => {
      let (x, y, z) = matrix_multiply(srgb_to_xyz_matrix, (r, g, b))
      XYZ(x, y, z)
    }
    _ => abort("Expected LinearRGB color")
  }
}

///|
/// Convert XYZ to LinearRGB
pub fn Color::from_xyz(self : Color) -> Color {
  match self {
    XYZ(x, y, z) => {
      let (r, g, b) = matrix_multiply(xyz_to_srgb_matrix, (x, y, z))
      LinearRGB(clamp(r, 0.0, 1.0), clamp(g, 0.0, 1.0), clamp(b, 0.0, 1.0))
    }
    _ => abort("Expected XYZ color")
  }
}

///| XYZ color space functions

///|
/// Create an XYZ color
pub fn Color::xyz(x : Double, y : Double, z : Double) -> Color {
  XYZ(x, y, z)
}

///|
/// Convert XYZ to LUV
pub fn Color::to_luv(self : Color) -> Color {
  match self {
    XYZ(x, y, z) => {
      let (xn, yn, zn) = white_point_d65

      // Calculate u' and v' for the color
      let denom = x + 15.0 * y + 3.0 * z
      let u_prime = if denom == 0.0 { 0.0 } else { 4.0 * x / denom }
      let v_prime = if denom == 0.0 { 0.0 } else { 9.0 * y / denom }

      // Calculate u'n and v'n for the white point
      let denom_n = xn + 15.0 * yn + 3.0 * zn
      let un_prime = 4.0 * xn / denom_n
      let vn_prime = 9.0 * yn / denom_n

      // Calculate L*
      let yr = y / yn
      let l_star = if yr > 0.008856 {
        116.0 * yr.pow(1.0 / 3.0) - 16.0
      } else {
        903.3 * yr
      }

      // Calculate u* and v*
      let u_star = 13.0 * l_star * (u_prime - un_prime)
      let v_star = 13.0 * l_star * (v_prime - vn_prime)
      LUV(l_star, u_star, v_star)
    }
    _ => abort("Expected XYZ color")
  }
}

///|
/// Convert LUV to XYZ
pub fn Color::from_luv(self : Color) -> Color {
  match self {
    LUV(l_star, u_star, v_star) => {
      let (xn, yn, zn) = white_point_d65

      // Calculate u'n and v'n for the white point
      let denom_n = xn + 15.0 * yn + 3.0 * zn
      let un_prime = 4.0 * xn / denom_n
      let vn_prime = 9.0 * yn / denom_n

      // Calculate Y
      let y = if l_star > 8.0 {
        yn * ((l_star + 16.0) / 116.0).pow(3.0)
      } else {
        yn * l_star / 903.3
      }

      // Calculate u' and v'
      let u_prime = if l_star == 0.0 {
        un_prime
      } else {
        u_star / (13.0 * l_star) + un_prime
      }
      let v_prime = if l_star == 0.0 {
        vn_prime
      } else {
        v_star / (13.0 * l_star) + vn_prime
      }

      // Calculate X and Z
      let x = if v_prime == 0.0 {
        0.0
      } else {
        y * 9.0 * u_prime / (4.0 * v_prime)
      }
      let z = if v_prime == 0.0 {
        0.0
      } else {
        y * (12.0 - 3.0 * u_prime - 20.0 * v_prime) / (4.0 * v_prime)
      }
      XYZ(x, y, z)
    }
    _ => abort("Expected LUV color")
  }
}

///| LUV color space functions

///|
/// Create a LUV color
pub fn Color::luv(l : Double, u : Double, v : Double) -> Color {
  LUV(l, u, v)
}

///| Color blending functions
/// These static methods blend two colors of the same type.

///|
/// Blend two RGB colors with a mixing ratio.
///
/// This method performs gamma-aware blending in RGB space. While not as
/// physically accurate as linear blending, it's suitable for UI colors
/// and simple color mixing.
///
/// # Parameters
/// - `color1`: First RGB color
/// - `color2`: Second RGB color  
/// - `mix`: Mixing ratio (0.0 = 100% first color, 1.0 = 100% second color)
///
/// # Returns
/// A new `Color` representing the blended result
///
/// # Panics
/// Aborts if either color is not in RGB color space
///
/// # Example
/// ```moonbit
/// let red = @colors.Color::rgb(255, 0, 0)
/// let blue = @colors.Color::rgb(0, 0, 255)
/// 
/// let purple = @colors.Color::blend_rgb(red, blue, 0.5)  // RGB(128, 0, 128)
/// 
/// inspect(purple, content="RGB(128, 0, 128)")
/// ```
pub fn Color::blend_rgb(color1 : Color, color2 : Color, mix : Double) -> Color {
  match (color1, color2) {
    (RGB(r1, g1, b1), RGB(r2, g2, b2)) => {
      let mix_clamped = clamp(mix, 0.0, 1.0)
      let r = (r1.to_double() * (1.0 - mix_clamped) +
      r2.to_double() * mix_clamped +
      0.5).to_int()
      let g = (g1.to_double() * (1.0 - mix_clamped) +
      g2.to_double() * mix_clamped +
      0.5).to_int()
      let b = (b1.to_double() * (1.0 - mix_clamped) +
      b2.to_double() * mix_clamped +
      0.5).to_int()
      RGB(r, g, b)
    }
    _ => abort("Both colors must be RGB for RGB blending")
  }
}

///|
/// Blend two LinearRGB colors with a mixing ratio
pub fn Color::blend_linear(
  color1 : Color,
  color2 : Color,
  mix : Double,
) -> Color {
  match (color1, color2) {
    (LinearRGB(r1, g1, b1), LinearRGB(r2, g2, b2)) => {
      let mix_clamped = clamp(mix, 0.0, 1.0)
      let r = r1 * (1.0 - mix_clamped) + r2 * mix_clamped
      let g = g1 * (1.0 - mix_clamped) + g2 * mix_clamped
      let b = b1 * (1.0 - mix_clamped) + b2 * mix_clamped
      LinearRGB(r, g, b)
    }
    _ => abort("Both colors must be LinearRGB for linear blending")
  }
}

///| Universal conversion methods
/// These methods can convert from any color space to any other color space,
/// performing all necessary intermediate conversions automatically.

///|
/// Convert any color to RGB color space.
///
/// This method performs all necessary intermediate conversions to transform
/// the color from any supported color space to RGB. The conversion path is:
/// - RGB → RGB (identity)
/// - LinearRGB → RGB (gamma correction)
/// - XYZ → LinearRGB → RGB
/// - LUV → XYZ → LinearRGB → RGB
///
/// # Parameters
/// - `self`: Color in any supported color space
///
/// # Returns
/// A new `Color` in RGB color space
///
/// # Example
/// ```moonbit
/// let xyz_color = @colors.Color::xyz(41.24, 21.26, 1.93)
/// let rgb_color = xyz_color.as_rgb()  // Converts XYZ → LinearRGB → RGB
/// 
/// inspect(rgb_color, content="RGB(255, 0, 0)")
/// ```
pub fn Color::as_rgb(self : Color) -> Color {
  match self {
    RGB(_, _, _) => self
    LinearRGB(_, _, _) => self.from_linear()
    XYZ(_, _, _) => self.from_xyz().from_linear()
    LUV(_, _, _) => self.from_luv().from_xyz().from_linear()
  }
}

///|
/// Convert any color to LinearRGB
pub fn Color::as_linear_rgb(self : Color) -> Color {
  match self {
    RGB(_, _, _) => self.to_linear()
    LinearRGB(_, _, _) => self
    XYZ(_, _, _) => self.from_xyz()
    LUV(_, _, _) => self.from_luv().from_xyz()
  }
}

///|
/// Convert any color to XYZ
pub fn Color::as_xyz(self : Color) -> Color {
  match self {
    RGB(_, _, _) => self.to_linear().to_xyz()
    LinearRGB(_, _, _) => self.to_xyz()
    XYZ(_, _, _) => self
    LUV(_, _, _) => self.from_luv()
  }
}

///|
/// Convert any color to LUV
pub fn Color::as_luv(self : Color) -> Color {
  match self {
    RGB(_, _, _) => self.to_linear().to_xyz().to_luv()
    LinearRGB(_, _, _) => self.to_xyz().to_luv()
    XYZ(_, _, _) => self.to_luv()
    LUV(_, _, _) => self
  }
}
