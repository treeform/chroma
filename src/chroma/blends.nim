## Blending modes.
import chroma

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
    else: Normal

proc min*(target, blend: Color): Color =
  result.r = min(target.r, blend.r)
  result.g = min(target.g, blend.g)
  result.b = min(target.b, blend.b)
  result.a = min(target.a, blend.a)

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

# converter floatToColor(v: float32): Color =
#   result.r = v
#   result.g = v
#   result.b = v
#   result.a = v

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

# proc normal(target, blend: Color): Color =
#   let a = blend.a
#   result.r = target.r * (1-a) + blend.r * a
#   result.g = target.g * (1-a) + blend.g * a
#   result.b = target.b * (1-a) + blend.b * a
#   result.a = max(target.a, blend.a)

proc mix*(blendMode: BlendMode, target, blend: Color): Color =

  if blend.a == 0: return target
  if target.a == 0: return blend

  result = case blendMode
  of Normal:       target * (1 - blend.a) + blend * blend.a
  of Darken:       min(target, blend)
  of Multiply:     target * blend
  of LinearBurn:   target + blend - 1
  of ColorBurn:    1 - (1 - target) / blend # TODO: fix
  of Lighten:      max(target, blend)
  of Screen:       1 - (1 - target) * (1 - blend)
  of LinearDodge:  target + blend
  of ColorDodge:   target / (1 - blend)
  of Overlay:      (target > 0.5) * (1 - (1-2*(target-0.5)) * (1-blend)) + (target <= 0.5) * ((2*target) * blend)
  of SoftLight:    (blend > 0.5) * (1 - (1-target) * (1-(blend-0.5))) + (blend <= 0.5) * (target * (blend+0.5)) # TODO: fix
  of HardLight:    (blend > 0.5) * (1 - (1-target) * (1-2*(blend-0.5))) + (blend <= 0.5) * (target * (2*blend)) # TODO: fix
  of Difference:   abs(target - blend)
  of Exclusion:    0.5 - 2*(target-0.5)*(blend-0.5)

  of Hue:          min(target, blend)
  of Saturation:   min(target, blend)
  of Color:        min(target, blend)
  of Luminosity:   min(target, blend)

  result.a = (blend.a + target.a * (1.0 - blend.a))

var blendCount*: int

proc mix*(blendMode: BlendMode, target, blend: ColorRGBA): ColorRGBA =
  if blendMode == Normal:
    if target.a == 0: return blend
    let blendAComp = 255 - blend.a
    result.r = ((target.r.uint16 * blendAComp + blend.r.uint16 * blend.a) div 255).uint8
    result.g = ((target.g.uint16 * blendAComp + blend.g.uint16 * blend.a) div 255).uint8
    result.b = ((target.b.uint16 * blendAComp + blend.b.uint16 * blend.a) div 255).uint8
    result.a = (blend.a.uint16 + (target.a.uint16 * blendAComp) div 255).uint8
    inc blendCount
  else:
    return blendMode.mix(target.color, blend.color).rgba
