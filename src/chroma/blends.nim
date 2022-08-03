import colortypes, std/math

proc `*`*(c: Color, v: float32): Color {.inline.} =
  ## Multiply color by a value.
  result.r = c.r * v
  result.g = c.g * v
  result.b = c.b * v
  result.a = c.a * v

proc `/`*(c: Color, v: float32): Color {.inline.} =
  ## Divide color by a value.
  result.r = c.r / v
  result.g = c.g / v
  result.b = c.b / v
  result.a = c.a / v

proc `+`*(c: Color, v: float32): Color {.inline.} =
  ## Add a value to a color
  result.r = c.r + v
  result.g = c.g + v
  result.b = c.b + v
  result.a = c.a + v

proc `+`*(v: float32, c: Color): Color {.inline.} =
  ## Add a value to a color
  c + v

proc `-`*(c: Color, v: float32): Color {.inline.} =
  ## Subtract a value from a color
  result.r = c.r - v
  result.g = c.g - v
  result.b = c.b - v
  result.a = c.a - v

proc `-`*(v: float32, c: Color): Color {.inline.} =
  ## Subtract a value from a color
  c - v

proc screen(backdrop, source: float32): float32 {.inline.} =
  1 - (1 - backdrop) * (1 - source)

proc hardLight(backdrop, source: float32): float32 {.inline.} =
  if source <= 0.5:
    backdrop * 2 * source
  else:
    screen(backdrop, 2 * source - 1)

proc softLight(backdrop, source: float32): float32 {.inline.} =
  ## Pegtop
  (1 - 2 * source) * backdrop ^ 2 + 2 * source * backdrop

proc lum(C: Color): float32 {.inline.} =
  0.3 * C.r + 0.59 * C.g + 0.11 * C.b

proc clipColor(C: var Color) {.inline.} =
  let
    L = lum(C)
    n = min([C.r, C.g, C.b])
    x = max([C.r, C.g, C.b])
  if n < 0:
      C = L + (((C - L) * L) / (L - n))
  if x > 1:
      C = L + (((C - L) * (1 - L)) / (x - L))

proc setLum(C: Color, l: float32): Color {.inline.} =
  let d = l - lum(C)
  result.r = C.r + d
  result.g = C.g + d
  result.b = C.b + d
  clipColor(result)

proc sat(C: Color): float32 {.inline.} =
  max([C.r, C.g, C.b]) - min([C.r, C.g, C.b])

proc setSat(C: Color, s: float32): Color {.inline.} =
  let satC = sat(C)
  if satC > 0:
    result = (C - min([C.r, C.g, C.b])) * s / satC

proc alphaFix(backdrop, source, mixed: Color): Color =
  result.a = (source.a + backdrop.a * (1.0 - source.a))
  if result.a == 0:
    return

  let
    t0 = source.a * (1 - backdrop.a)
    t1 = source.a * backdrop.a
    t2 = (1 - source.a) * backdrop.a

  result.r = t0 * source.r + t1 * mixed.r + t2 * backdrop.r
  result.g = t0 * source.g + t1 * mixed.g + t2 * backdrop.g
  result.b = t0 * source.b + t1 * mixed.b + t2 * backdrop.b

  result.r /= result.a
  result.g /= result.a
  result.b /= result.a

proc blendNormal*(backdrop, source: Color): Color {.inline.} =
  result = source
  result = alphaFix(backdrop, source, result)

proc blendDarken*(backdrop, source: Color): Color {.inline.} =
  result.r = min(backdrop.r, source.r)
  result.g = min(backdrop.g, source.g)
  result.b = min(backdrop.b, source.b)
  result = alphaFix(backdrop, source, result)

proc blendMultiply*(backdrop, source: Color): Color {.inline.} =
  result.r = backdrop.r * source.r
  result.g = backdrop.g * source.g
  result.b = backdrop.b * source.b
  result = alphaFix(backdrop, source, result)

proc blendLinearBurn*(backdrop, source: Color): Color {.inline.} =
  result.r = backdrop.r + source.r - 1
  result.g = backdrop.g + source.g - 1
  result.b = backdrop.b + source.b - 1
  result = alphaFix(backdrop, source, result)

proc blendColorBurn*(backdrop, source: Color): Color {.inline.} =
  proc blend(backdrop, source: float32): float32 {.inline.} =
    if backdrop == 1:
      1.0
    elif source == 0:
      0.0
    else:
      1.0 - min(1, (1 - backdrop) / source)
  result.r = blend(backdrop.r, source.r)
  result.g = blend(backdrop.g, source.g)
  result.b = blend(backdrop.b, source.b)
  result = alphaFix(backdrop, source, result)

proc blendLighten*(backdrop, source: Color): Color {.inline.} =
  result.r = max(backdrop.r, source.r)
  result.g = max(backdrop.g, source.g)
  result.b = max(backdrop.b, source.b)
  result = alphaFix(backdrop, source, result)

proc blendScreen*(backdrop, source: Color): Color {.inline.} =
  result.r = screen(backdrop.r, source.r)
  result.g = screen(backdrop.g, source.g)
  result.b = screen(backdrop.b, source.b)
  result = alphaFix(backdrop, source, result)

proc blendLinearDodge*(backdrop, source: Color): Color {.inline.} =
  result.r = backdrop.r + source.r
  result.g = backdrop.g + source.g
  result.b = backdrop.b + source.b
  result = alphaFix(backdrop, source, result)

proc blendColorDodge*(backdrop, source: Color): Color {.inline.} =
  proc blend(backdrop, source: float32): float32 {.inline.} =
    if backdrop == 0:
      0.0
    elif source == 1:
      1.0
    else:
      min(1, backdrop / (1 - source))
  result.r = blend(backdrop.r, source.r)
  result.g = blend(backdrop.g, source.g)
  result.b = blend(backdrop.b, source.b)
  result = alphaFix(backdrop, source, result)

proc blendOverlay*(backdrop, source: Color): Color {.inline.} =
  result.r = hardLight(source.r, backdrop.r)
  result.g = hardLight(source.g, backdrop.g)
  result.b = hardLight(source.b, backdrop.b)
  result = alphaFix(backdrop, source, result)

proc blendHardLight*(backdrop, source: Color): Color {.inline.} =
  result.r = hardLight(backdrop.r, source.r)
  result.g = hardLight(backdrop.g, source.g)
  result.b = hardLight(backdrop.b, source.b)
  result = alphaFix(backdrop, source, result)

proc blendSoftLight*(backdrop, source: Color): Color {.inline.} =
  result.r = softLight(backdrop.r, source.r)
  result.g = softLight(backdrop.g, source.g)
  result.b = softLight(backdrop.b, source.b)
  result = alphaFix(backdrop, source, result)

proc blendDifference*(backdrop, source: Color): Color {.inline.} =
  result.r = abs(backdrop.r - source.r)
  result.g = abs(backdrop.g - source.g)
  result.b = abs(backdrop.b - source.b)
  result = alphaFix(backdrop, source, result)

proc blendExclusion*(backdrop, source: Color): Color {.inline.} =
  proc blend(backdrop, source: float32): float32 {.inline.} =
    backdrop + source - 2 * backdrop * source
  result.r = blend(backdrop.r, source.r)
  result.g = blend(backdrop.g, source.g)
  result.b = blend(backdrop.b, source.b)
  result = alphaFix(backdrop, source, result)

proc blendColor*(backdrop, source: Color): Color {.inline.} =
  result = setLum(source, lum(backdrop))
  result = alphaFix(backdrop, source, result)

proc blendLuminosity*(backdrop, source: Color): Color {.inline.} =
  result = setLum(backdrop, lum(source))
  result = alphaFix(backdrop, source, result)

proc blendHue*(backdrop, source: Color): Color {.inline.} =
  result = setLum(setSat(source, sat(backdrop)), lum(backdrop))
  result = alphaFix(backdrop, source, result)

proc blendSaturation*(backdrop, source: Color): Color {.inline.} =
  result = setLum(setSat(backdrop, sat(source)), lum(backdrop))
  result = alphaFix(backdrop, source, result)
