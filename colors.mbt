///| Color type definitions and core functionality
/// A pure MoonBit library for manipulating colors in different color spaces

///|
/// Color type representing different color spaces
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
/// Create an RGB color from 8-bit values (0-255)
pub fn rgb(r : Int, g : Int, b : Int) -> Color {
  let r_clamped = if r < 0 { 0 } else if r > 255 { 255 } else { r }
  let g_clamped = if g < 0 { 0 } else if g > 255 { 255 } else { g }
  let b_clamped = if b < 0 { 0 } else if b > 255 { 255 } else { b }
  RGB(r_clamped, g_clamped, b_clamped)
}

///|
/// Convert RGB to LinearRGB
pub fn rgb_to_linear(color : Color) -> Color {
  match color {
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
pub fn linear_to_rgb(color : Color) -> Color {
  match color {
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
/// Create a LinearRGB color from normalized values (0.0-1.0)
pub fn linear_rgb(r : Double, g : Double, b : Double) -> Color {
  LinearRGB(clamp(r, 0.0, 1.0), clamp(g, 0.0, 1.0), clamp(b, 0.0, 1.0))
}

///|
/// Convert LinearRGB to XYZ
pub fn linear_to_xyz(color : Color) -> Color {
  match color {
    LinearRGB(r, g, b) => {
      let (x, y, z) = matrix_multiply(srgb_to_xyz_matrix, (r, g, b))
      XYZ(x, y, z)
    }
    _ => abort("Expected LinearRGB color")
  }
}

///|
/// Convert XYZ to LinearRGB
pub fn xyz_to_linear(color : Color) -> Color {
  match color {
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
pub fn xyz(x : Double, y : Double, z : Double) -> Color {
  XYZ(x, y, z)
}

///|
/// Convert XYZ to LUV
pub fn xyz_to_luv(color : Color) -> Color {
  match color {
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
pub fn luv_to_xyz(color : Color) -> Color {
  match color {
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
pub fn luv(l : Double, u : Double, v : Double) -> Color {
  LUV(l, u, v)
}

///| Color blending functions

///|
/// Blend two RGB colors with a mixing ratio
/// mix: 0.0 = first color, 1.0 = second color
pub fn blend_rgb(color1 : Color, color2 : Color, mix : Double) -> Color {
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
pub fn blend_linear(color1 : Color, color2 : Color, mix : Double) -> Color {
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

///| Conversion helper functions

///|
/// Convert any color to RGB
pub fn to_rgb(color : Color) -> Color {
  match color {
    RGB(_, _, _) => color
    LinearRGB(_, _, _) => linear_to_rgb(color)
    XYZ(_, _, _) => linear_to_rgb(xyz_to_linear(color))
    LUV(_, _, _) => linear_to_rgb(xyz_to_linear(luv_to_xyz(color)))
  }
}

///|
/// Convert any color to LinearRGB
pub fn to_linear_rgb(color : Color) -> Color {
  match color {
    RGB(_, _, _) => rgb_to_linear(color)
    LinearRGB(_, _, _) => color
    XYZ(_, _, _) => xyz_to_linear(color)
    LUV(_, _, _) => xyz_to_linear(luv_to_xyz(color))
  }
}

///|
/// Convert any color to XYZ
pub fn to_xyz(color : Color) -> Color {
  match color {
    RGB(_, _, _) => linear_to_xyz(rgb_to_linear(color))
    LinearRGB(_, _, _) => linear_to_xyz(color)
    XYZ(_, _, _) => color
    LUV(_, _, _) => luv_to_xyz(color)
  }
}

///|
/// Convert any color to LUV
pub fn to_luv(color : Color) -> Color {
  match color {
    RGB(_, _, _) => xyz_to_luv(linear_to_xyz(rgb_to_linear(color)))
    LinearRGB(_, _, _) => xyz_to_luv(linear_to_xyz(color))
    XYZ(_, _, _) => xyz_to_luv(color)
    LUV(_, _, _) => color
  }
}
