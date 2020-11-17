## Blending modes.
import chroma, math

type BlendMode* = enum
  Normal
  Darken
  Multiply
  LinearBurn
  ColorBurn
  Lighten
  Screen
  LinearDodge
  ColorDodge
  Overlay
  SoftLight
  HardLight
  Difference
  Exclusion
  Hue
  Saturation
  Color
  Luminosity
  Mask  ## Special blend mode that is used for masking
  Copy  ## Special that does not blend but copies the pixels from target.

proc parseBlendMode*(s: string): BlendMode =
  case s:
    of "NORMAL": Normal
    of "DARKEN": Darken
    of "MULTIPLY": Multiply
    of "LINEAR_BURN": LinearBurn
    of "COLOR_BURN": ColorBurn
    of "LIGHTEN": Lighten
    of "SCREEN": Screen
    of "LINEAR_DODGE": LinearDodge
    of "COLOR_DODGE": ColorDodge
    of "OVERLAY": Overlay
    of "SOFT_LIGHT": SoftLight
    of "HARD_LIGHT": HardLight
    of "DIFFERENCE": Difference
    of "EXCLUSION": Exclusion
    of "HUE": Hue
    of "SATURATION": Saturation
    of "COLOR": Color
    of "LUMINOSITY": Luminosity
    of "MASK": Mask
    of "COPY": Copy
    else: Normal

proc min*(target, blend: Color): Color =
  result.r = min(target.r, blend.r)
  result.g = min(target.g, blend.g)
  result.b = min(target.b, blend.b)
  result.a = min(target.a, blend.a)

proc min*(v: float32, blend: Color): Color =
  result.r = min(v, blend.r)
  result.g = min(v, blend.g)
  result.b = min(v, blend.b)
  result.a = min(v, blend.a)

proc max*(target, blend: Color): Color =
  result.r = max(target.r, blend.r)
  result.g = max(target.g, blend.g)
  result.b = max(target.b, blend.b)
  result.a = max(target.a, blend.a)

proc abs*(target: Color): Color =
  result.r = abs(target.r)
  result.g = abs(target.g)
  result.b = abs(target.b)
  result.a = abs(target.a)

proc `+`*(target, blend: Color): Color =
  result.r = target.r + blend.r
  result.g = target.g + blend.g
  result.b = target.b + blend.b
  result.a = target.a + blend.a

proc `+`*(target: Color, v: float32): Color =
  result.r = target.r + v
  result.g = target.g + v
  result.b = target.b + v
  result.a = target.a + v

proc `+`*(v: float32, c: Color): Color =
  result.r = v + c.r
  result.g = v + c.g
  result.b = v + c.b
  result.a = v + c.a

proc `-`*(target, blend: Color): Color =
  result.r = target.r - blend.r
  result.g = target.g - blend.g
  result.b = target.b - blend.b
  result.a = target.a - blend.a

proc `*`*(target, blend: Color): Color =
  result.r = target.r * blend.r
  result.g = target.g * blend.g
  result.b = target.b * blend.b
  result.a = target.a * blend.a

proc `*`*(target: Color, v: float32): Color =
  result.r = target.r * v
  result.g = target.g * v
  result.b = target.b * v
  result.a = target.a * v

proc `*`*(v: float32, target: Color): Color =
  target * v

proc `/`*(target, blend: Color): Color =
  result.r = target.r / blend.r
  result.g = target.g / blend.g
  result.b = target.b / blend.b
  result.a = target.a / blend.a

proc `/`*(target: Color, v: float32): Color =
  result.r = target.r / v
  result.g = target.g / v
  result.b = target.b / v
  result.a = target.a / v

proc `-`*(v: float32, color: Color): Color =
  result.r = v - color.r
  result.g = v - color.g
  result.b = v - color.b
  result.a = v - color.a

proc `-`*(color: Color, v: float32): Color =
  result.r = color.r - v
  result.g = color.g - v
  result.b = color.b - v
  result.a = color.a - v

proc `>`*(color: Color, v: float32): Color =
  result.r = if color.r > v: 1.0 else: 0.0
  result.g = if color.g > v: 1.0 else: 0.0
  result.b = if color.b > v: 1.0 else: 0.0
  result.a = if color.a > v: 1.0 else: 0.0

proc `<=`*(color: Color, v: float32): Color =
  result.r = if color.r <= v: 1.0 else: 0.0
  result.g = if color.g <= v: 1.0 else: 0.0
  result.b = if color.b <= v: 1.0 else: 0.0
  result.a = if color.a <= v: 1.0 else: 0.0

proc mix*(blendMode: BlendMode, target, blend: Color): Color =

  if blendMode == Mask:
    result.r = target.r
    result.g = target.g
    result.b = target.b
    result.a = min(target.a, blend.a)
    return
  elif blendMode == Copy:
    result = target

  if blend.a == 0: return target
  if target.a == 0: return blend

  result = case blendMode
  of Normal:       target * (1 - blend.a) + blend * blend.a
  of Darken:       min(target, blend)
  of Multiply:     target * blend
  of LinearBurn:   target + blend - 1
  of ColorBurn:    1 - min(1, (1 - target) / blend) #1 - (1 - target) / blend # TODO: fix
  of Lighten:      max(target, blend)
  of Screen:       1 - (1 - target) * (1 - blend)
  of LinearDodge:  target + blend
  of ColorDodge:   target / (1 - blend)
  of Overlay:
    let blend = blend * blend.a
    (target > 0.5) * (1 - (1-2*(target-0.5)) * (1-blend)) + (target <= 0.5) * ((2*target) * blend)
  of SoftLight:    (blend > 0.5) * (1 - (1-target) * (1-(blend-0.5))) + (blend <= 0.5) * (target * (blend+0.5)) # TODO: fix
  of HardLight:    (blend > 0.5) * (1 - (1-target) * (1-2*(blend-0.5))) + (blend <= 0.5) * (target * (2*blend)) # TODO: fix
  of Difference:   abs(target - blend)
  of Exclusion:    0.5 - 2*(target-0.5)*(blend-0.5)

  of Hue:          min(target, blend)
  of Saturation:   min(target, blend)
  of Color:        min(target, blend)
  of Luminosity:   min(target, blend)

  of Mask:         target
  of Copy:         target

  result.a = (blend.a + target.a * (1.0 - blend.a))

var blendCount*: int


proc mix2*(blendMode: BlendMode, target, blend: Color): Color =

  if blendMode == Mask:
    result.r = target.r
    result.g = target.g
    result.b = target.b
    result.a = min(target.a, blend.a)
    return
  elif blendMode == Copy:
    result = target
    return

  proc multiply(Cb, Cs: float32): float32 =
    Cb * Cs

  proc screen(Cb, Cs: float32): float32 =
    1 - (1 - Cb) * (1 - Cs)

  proc hardLight(Cb, Cs: float32): float32 =
    if Cs <= 0.5: multiply(Cb, 2 * Cs)
    else: screen(Cb, 2 * Cs - 1)

  proc softLight(Cb, Cs: float32): float32 =
    proc D(cb: float32): float32 =
      if Cb <= 0.25:
        ((16 * Cb - 12) * Cb + 4) * Cb
      else:
        sqrt(Cb)
    if Cs <= 0.5:
      return Cb - (1 - 2 * Cs) * Cb * (1 - Cb)
    else:
      return Cb + (2 * Cs - 1) * (D(Cb) - Cb)

  proc Lum(C: Color): float32 =
    0.3 * C.r + 0.59 * C.g + 0.11 * C.b

  proc ClipColor(C: Color): Color =
    let
      L = Lum(C)
      n = min([C.r, C.g, C.b])
      x = max([C.r, C.g, C.b])
    var
      C = C
    if n < 0:
        C = L + (((C - L) * L) / (L - n))
    if x > 1:
        C = L + (((C - L) * (1 - L)) / (x - L))
    return C

  proc SetLum(C: Color, l: float32): Color =
    let
      d = l - Lum(C)
    result.r = C.r + d
    result.g = C.g + d
    result.b = C.b + d
    return ClipColor(result)

  proc Sat(C: Color): float32 =
    max([C.r, C.g, C.b]) - min([C.r, C.g, C.b])

  # proc SetSat(C: Color, s: float32): Color =
  #   let
  #     Cmax = max([C.r, C.g, C.b])
  #     Cmin = min([C.r, C.g, C.b])
  #   if Cmax > Cmin:
  #     let
  #       Cmid = (((Cmid - Cmin) x s) / (Cmax - Cmin))
  #       Cmax = s
  #   else
  #       Cmid = Cmax = 0
  #   Cmin = 0
  #   return C

  proc blendChannel(blendMode: BlendMode, Cb, Cs: float32): float32 =
    result = case blendMode
    of Normal:       Cs
    of Darken:       min(Cb, Cs)
    of Multiply:     multiply(Cb, Cs)
    of LinearBurn:   Cb + Cs - 1
    of ColorBurn:
      if Cb == 1:    1.0
      elif Cs == 0:  0.0
      else:          1.0 - min(1, (1 - Cb) / Cs)
    of Lighten:      max(Cb, Cs)
    of Screen:       screen(Cb, Cs)
    of LinearDodge:  Cb + Cs
    of ColorDodge:
      if Cb == 0:    0.0
      elif Cs == 1:  1.0
      else:          min(1, Cb / (1 - Cs))
    of Overlay:      hardLight(Cs, Cb)
    of HardLight:    hardLight(Cb, Cs)
    of SoftLight:    softLight(Cb, Cs)
    of Difference:   abs(Cb - Cs)
    of Exclusion:    Cb + Cs - 2 * Cb * Cs
    else: 0.0
  let Cb = target
  let Cs = blend

  var mixed: Color
  if blendMode == Color:
    mixed = SetLum(Cs, Lum(Cb))
    #mixed = hsl(Cb.hsl.h, Cb.hsl.s, Cs.hsl.l).color
  elif blendMode == Luminosity:
    mixed = SetLum(Cb, Lum(Cs))
    #mixed = hsl(Cs.hsl.h, Cs.hsl.s, Cb.hsl.l).color
  elif blendMode == Hue:
    mixed = hsl(Cs.hsl.h, Cb.hsl.s, Cb.hsl.l).color
  elif blendMode == Saturation:
    mixed = hsl(Cb.hsl.h, Cs.hsl.s, Cb.hsl.l).color
  else:
    mixed.r = blendMode.blendChannel(Cb.r, Cs.r)
    mixed.g = blendMode.blendChannel(Cb.g, Cs.g)
    mixed.b = blendMode.blendChannel(Cb.b, Cs.b)

  let ab = Cb.a
  let As = Cs.a
  result.r = As * (1 - ab) * Cs.r + As * ab * mixed.r + (1 - As) * ab * Cb.r
  result.g = As * (1 - ab) * Cs.g + As * ab * mixed.g + (1 - As) * ab * Cb.g
  result.b = As * (1 - ab) * Cs.b + As * ab * mixed.b + (1 - As) * ab * Cb.b

  result.a = (blend.a + target.a * (1.0 - blend.a))
  result.r /= result.a
  result.g /= result.a
  result.b /= result.a



proc mix*(blendMode: BlendMode, target, blend: ColorRGBA): ColorRGBA =
  return blendMode.mix2(target.color, blend.color).rgba

  # if blendMode == Normal:
  #   # Fast pass
  #   # target * (1 - blend.a) + blend * blend.a
  #   if target.a == 0: return blend
  #   let blendAComp = 255 - blend.a
  #   result.r = ((target.r.uint16 * blendAComp + blend.r.uint16 * blend.a) div 255).uint8
  #   result.g = ((target.g.uint16 * blendAComp + blend.g.uint16 * blend.a) div 255).uint8
  #   result.b = ((target.b.uint16 * blendAComp + blend.b.uint16 * blend.a) div 255).uint8
  #   result.a = (blend.a.uint16 + (target.a.uint16 * blendAComp) div 255).uint8
  #   inc blendCount
  # elif blendMode == Mask:
  #   result.r = target.r
  #   result.g = target.g
  #   result.b = target.b
  #   result.a = min(target.a, blend.a)
  # elif blendMode == COPY:
  #   result = target
  # else:
  #   return blendMode.mix(target.color, blend.color).rgba
