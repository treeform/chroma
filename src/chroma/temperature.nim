import math, colortypes

proc slopeUp(k, a, b, c, d, e: float): float =
  let kp = k + e
  a + b * kp.pow(3) * exp(c*kp) + d * ln(k)

proc slopeDown(k, a, b, c, d, e: float): float =
  let kp = k + e
  a + b * kp.pow(c) + d * ln(k)

proc fromLinear(v: float): float =
  if v > 0.0031308:
    ((1.055 * pow(v, 1/2.4)) - 0.055)
  else:
    v * 12.92

proc fromTemperature*(kelvin: float): Color =
  ## Compute color from temperature of "ideal black-body radiator".
  ## Used in applications in lighting, photography, videography, publishing,
  ## manufacturing, astrophysics, horticulture, and other fields.
  ## See: https://en.wikipedia.org/wiki/Color_temperature

  result.a = 1
  let temperature = kelvin / 10000.0

  # Calculate red
  if kelvin <= 6600:
    result.r = 1.0
  else:
    result.r = fromLinear(slopeDown(
      temperature,
      0.32068362618584273,
      0.19668730877673762,
      -1.5139012907556737,
      -0.013883432789258415,
      -0.21298613432655075
    ))

  # Calculate green
  if kelvin <= 6600:
    result.g = fromLinear(slopeUp(
      temperature,
      1.226916242502167,
      -1.3109482654223614,
      -5.089297600846147,
      0.6453936305542096,
      -0.44267061967913873
    ))
  else:
    result.g = fromLinear(slopeDown(
      temperature,
      0.4860175851734596,
      0.1802139719519286,
      -1.397716496795082,
      -0.00803698899233844,
      -0.14573069517701578
    ))

  # Calculate blue
  if kelvin >= 6600:
    result.b = 1
  elif kelvin <= 1900:
    result.b = 0
  else:
    result.b = fromLinear(slopeUp(
      temperature,
      1.677499032830161,
      -0.02313594016938082,
      -4.221279555918655,
      1.6550275798913296,
      -1.1367244820333684
    ))
