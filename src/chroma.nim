##
## **Everything you want to do with colors.**
##

import strutils, math, tables, hashes
import chroma / [names, colortypes, transformations]
export colortypes
export transformations.color


# utility functions
proc clamp(n, a, b: float32): float32 = min(max(a, n), b)
proc toHex(a: float32): string = toHex(int(a))


proc `$`*(c: Color): string =
  ## returns colors as "(r, g, b, a)"
  "(" & $c.r & ", " & $c.g & ", " & $c.b & ", " & $c.a & ")"


proc hash*(c: Color): Hash =
  var h: Hash = 0
  h = h !& hash(c.r)
  h = h !& hash(c.g)
  h = h !& hash(c.b)
  h = h !& hash(c.a)
  result = !$h


proc almostEqual*(a, b: Color, ep = 0.01): bool =
  ## Returns true if colors are close
  if abs(a.r - b.r) > ep: return false
  if abs(a.g - b.g) > ep: return false
  if abs(a.b - b.b) > ep: return false
  return true


proc c2n(hex: string, i: int): int =
  let c = ord(hex[i])
  case c
  of ord('0') .. ord('9'): return c - ord('0')
  of ord('a') .. ord('f'): return 10 + c - ord('a')
  of ord('A') .. ord('F'): return 10 + c - ord('A')
  else:
    raise newException(InvalidColor, "format is not hex")


proc parseHex*(hex: string): Color =
  ## parse colors like
  ## * FF0000 -> red
  ## * 0000FF -> blue
  ## * FFFFFF -> white
  assert hex.len == 6
  result.r = float32(c2n(hex, 0) * 16 + c2n(hex, 1)) / 255
  result.g = float32(c2n(hex, 2) * 16 + c2n(hex, 3)) / 255
  result.b = float32(c2n(hex, 4) * 16 + c2n(hex, 5)) / 255
  result.a = 1.0


proc toHex*(c: Color): string =
  ## Formats color as hex (upper case):
  ## * red -> FF0000
  ## * blue -> 0000FF
  ## * white -> FFFFFF
  proc pair(n: float32): string =
    toHex(n*255)[^2..^1]
  return pair(c.r) & pair(c.g) & pair(c.b)


proc parseHexAlpha*(hex: string): Color =
  ## parse colors like
  ## * FF0000FF -> red
  ## * 0000FFFF -> blue
  ## * FFFFFFFF -> white
  ## * 000000FF -> opaque  black
  ## * 00000000 -> transparent black
  assert hex.len == 8
  result.r = float32(c2n(hex, 0) * 16 + c2n(hex, 1)) / 255
  result.g = float32(c2n(hex, 2) * 16 + c2n(hex, 3)) / 255
  result.b = float32(c2n(hex, 4) * 16 + c2n(hex, 5)) / 255
  result.a = float32(c2n(hex, 6) * 16 + c2n(hex, 7)) / 255


proc toHexAlpha*(c: Color): string =
  ## Formats color as hex (upper case):
  ## * red -> FF0000FF
  ## * blue -> 0000FFFF
  ## * white -> FFFFFFFF
  ## * opaque  black -> 000000FF
  ## * transparent black -> 00000000
  proc pair(n: float32): string =
    toHex(n*255)[^2..^1]
  return pair(c.r) & pair(c.g) & pair(c.b) & pair(c.a)


proc parseHtmlHex*(hex: string): Color =
  ## parse colors with leading '#' like:
  ## * #FF0000 -> red
  ## * #0000ff -> blue
  ## * #ffffff -> white
  if hex[0] != '#':
    raise newException(InvalidColor, "Expected '#'")
  parseHex(hex[1..^1])


proc toHtmlHex*(c: Color): string =
  ## Formats color as HTML hex (upper case):
  ## * red -> #FF0000
  ## * blue -> #0000FF
  ## * white -> #FFFFFF
  return '#' & c.toHex()


proc parseHtmlHexTiny*(hex: string): Color =
  ## parse colors with leading '#' and 3 hex numbers like:
  ## * #F00 -> red
  ## * #0ff -> blue
  ## * #fff -> white
  if hex[0] != '#':
    raise newException(InvalidColor, "Expected '#'")
  assert hex.len == 4
  result.r = float32(c2n(hex, 1)) / 15
  result.g = float32(c2n(hex, 2)) / 15
  result.b = float32(c2n(hex, 3)) / 15
  result.a = 1.0


proc toHtmlHexTiny*(c: Color): string =
  ## Formats color as HTML 3 hex numbers (upper case):
  ## * red -> #F00
  ## * blue -> #00F
  ## * white -> #FFF
  proc pair(n: float32): string =
    toHex(n*15)[^1..^1]
  return '#' & pair(c.r) & pair(c.g) & pair(c.b)


proc parseHtmlRgb*(text: string): Color =
  ## parse colors in html's rgb format:
  ## * rgb(255, 0, 0) -> red
  ## * rgb(0,0,255) -> blue
  ## * rgb(255,255,255) -> white

  if text[0..3] != "rgb(":
    raise newException(InvalidColor, "Expected 'rgb('")
  if text[^1] != ')':
    raise newException(InvalidColor, "Expected ')'")
  let inner = text[4..^2].replace(" ", "")
  let arr = inner.split(',')
  if arr.len != 3:
    raise newException(InvalidColor, "Expected 3 numbers in rgb()")
  result.r = min(1.0, parseFloat(arr[0]) / 255)
  result.g = min(1.0, parseFloat(arr[1]) / 255)
  result.b = min(1.0, parseFloat(arr[2]) / 255)
  result.a = 1.0


proc toHtmlRgb*(c: Color): string =
  ## parse colors in html's rgb format:
  ## * red -> rgb(255, 0, 0)
  ## * blue -> rgb(0,0,255)
  ## * white -> rgb(255,255,255)
  return "rgb(" &
    $int(c.r * 255) & ", " &
    $int(c.g * 255) & ", " &
    $int(c.b * 255) & ")"


proc parseHtmlRgba*(text: string): Color =
  ## parse colors in html's rgba format:
  ## * rgba(255, 0, 0, 1.0) -> red
  ## * rgba(0,0,255, 1.0) -> blue
  ## * rgba(255,255,255, 1.0) -> white
  ## * rgba(0,0,0,1.0) -> opaque  black
  ## * rgba(0,0,0,0.0) -> transparent black
  ##
  ## Note: rgb is 0-255, while alpha is 0 to 1.

  if text[0..4] != "rgba(":
    raise newException(InvalidColor, "Expected 'rgba('")
  if text[^1] != ')':
    raise newException(InvalidColor, "Expected ')'")
  let inner = text[5..^2].replace(" ", "")
  let arr = inner.split(',')
  if arr.len != 4:
    raise newException(InvalidColor, "Expected 4 numbers in rgba()")
  result.r = min(1.0, parseFloat(arr[0]) / 255)
  result.g = min(1.0, parseFloat(arr[1]) / 255)
  result.b = min(1.0, parseFloat(arr[2]) / 255)
  result.a = min(1.0, parseFloat(arr[3]))


proc toHtmlRgba*(c: Color): string =
  ## parse colors in html's rgb format:
  ## * red -> rgb(255, 0, 0)
  ## * blue -> rgb(0,0,255)
  ## * white -> rgb(255,255,255)
  return "rgba(" &
    $int(c.r * 255) & ", " &
    $int(c.g * 255) & ", " &
    $int(c.b * 255) & ", " &
    $c.a & ")"


proc rgb*(r, g, b: uint8): ColorRGB =
  ## Creates ColorRGB from intergers in 0-255 range like:
  ## * rgb(255,0,0) -> red
  ## * rgb(0,255,0) -> green
  ## * rgb(0,0,255) -> blue
  result.r = r
  result.g = g
  result.b = b

proc rgb*(c: Color): ColorRGB = RGB_to_RGB_type(c)
proc color*(c: ColorRGB): Color = RGB_type_to_RGB(c)


proc parseHtmlName*(text: string): Color =
  ## Parses HTML color as as a name
  ## * "red"
  ## * "blue"
  ## * "white"
  ## * "amber"
  ## * "Lavender Gray"
  let lowerName = text.toLowerAscii()
  if lowerName in colorNames:
    return parseHex(colorNames[lowerName])
  else:
    raise newException(InvalidColor, "Not a valid color name.")


proc parseHtmlColor*(colorText: string): Color =
  ## Parses HTML color any any of the formats:
  ## * #FFF
  ## * #FFFFFF
  ## * rgb(255, 255, 255)
  ## * rgba(255, 255, 255, 1.0)
  ## * white
  let text = colorText.strip()
  if text[0] == '#':
    if text.len == 4:
      return parseHtmlHexTiny(text)
    elif text.len == 7:
      return parseHtmlHex(text)
    else:
      raise newException(InvalidColor, "HTML color invalid.")
  elif text[0..3] == "rgba":
    return parseHtmlRgba(text)
  elif text[0..2] == "rgb":
    return parseHtmlRgb(text)
  else:
    return parseHtmlName(text)

proc rgba*(r, g, b, a: uint8): ColorRGBA =
  ## Creates ColorRGBA from intergers in 0-255 range like:
  ## * rgba(255,0,0) -> red
  ## * rgba(0,255,0) -> green
  ## * rgba(0,0,255) -> blue
  ## * rgba(0,0,0,255) -> opaque  black
  ## * rgba(0,0,0,0) -> transparent black
  ##
  ## Note: this is *not* like HTML's rgba where the alpha is 0 to 1.
  result.r = r
  result.g = g
  result.b = b
  result.a = a

proc rgba*(c: Color): ColorRGBA = RGB_to_RGBA(c)
proc color*(c: ColorRGBA): Color = RGBA_to_RGB(c)

# Convenience procs to convert from and to other colorspaces
proc cmy*(c: Color): ColorCMY = RGB_to_CMY(c)
proc color*(c: ColorCMY): Color = CMY_to_RGB(c)


proc cmyk*(c: Color): ColorCMYK = RGB_to_CMYK(c)
proc color*(c: ColorCMYK): Color = CMYK_to_RGB(c)


proc hsl*(c: Color): ColorHSL = RGB_to_HSL(c)
proc color*(c: ColorHSL): Color = HSL_to_RGB(c)

proc hsv*(c: Color): ColorHSV = RGB_to_HSV(c)
proc color*(c: ColorHSV): Color = HSV_to_RGB(c)

proc yuv*(c: Color): ColorYUV = RGB_to_YUV(c)
proc color*(c: ColorYUV): Color = YUV_to_RGB(c)


proc to*[T: SomeColor](c: T, toColor: typedesc): toColor =
  ## Allows conversion of transformation of a color in any
  ## colorspace into any other colorspace.
  when toColor is Color:
    result = c.asRGB
  elif toColor is ColorRGB:
    result = c.asRGB_type
  elif toColor is ColorRGBA:
    result = c.asRGBA
  elif toColor is ColorHSL:
    result = c.asHSL
  elif toColor is ColorHSV:
    result = c.asHSV
  elif toColor is ColorYUV:
    result = c.asYUV
  elif toColor is ColorCMY:
    result = c.asCMY
  elif toColor is ColorCMYK:
    result = c.asCMYK
  elif toColor is ColorLAB:
    result = c.asLAB
  elif toColor is ColorPolarLAB:
    result = c.asPolarLab
  elif toColor is ColorLUV:
    result = c.asLUV
  elif toColor is ColorPolarLUV:
    result = c.asPolarLab

# Color Functions

proc lighten*(color: Color, amount: float32): Color =
  ## Lightens the color by amount 0-1
  var hsl = color.hsl()
  hsl.l += 100 * amount
  hsl.l = clamp(hsl.l, 0, 100)
  result = color(hsl)
  result.a = color.a


proc darken*(color: Color, amount: float32): Color =
  ## Darkens the color by amount 0-1
  color.lighten(-amount)


proc saturate*(color: Color, amount: float32): Color =
  ## Saturates (makes brighter) the color by amount 0-1
  var hsl = color.hsl()
  hsl.s += 100 * amount
  hsl.s = clamp(hsl.s, 0, 100)
  result = color(hsl)
  result.a = color.a


proc desaturate*(color: Color, amount: float32): Color =
  ## Desaturate (makes grayer) the color by amount 0-1
  color.saturate(-amount)


proc spin*(color: Color, degrees: float32): Color =
  ## Rotates the hue of the color by degrees (0-360)
  var hsl = color.hsl()
  hsl.h += degrees
  if hsl.h < 0: hsl.h += 360
  if hsl.h >= 360: hsl.h -= 360
  result = color(hsl)
  result.a = color.a


proc mix*(a, b: Color): Color =
  ## Mixes two ColorRGBA colors together
  var c: Color
  c.r = (a.r + b.r) / 2.0
  c.g = (a.g + b.g) / 2.0
  c.b = (a.b + b.b) / 2.0
  c.a = (a.a + b.a) / 2.0
  return c


proc mixCMYK*(colorA, colorB: Color): Color =
  ## Mixes two colors together using CMYK
  let
    a = colorA.cmyk
    b = colorB.cmyk
  var c: ColorCMYK
  c.c = (a.c + b.c) / 2
  c.m = (a.m + b.m) / 2
  c.y = (a.y + b.y) / 2
  c.k = (a.k + b.k) / 2
  return c.color


proc mix*(a, b: ColorRGBA): ColorRGBA =
  ## Mixes two ColorRGBA colors together
  var c: ColorRGBA
  c.r = a.r div 2 + b.r div 2
  c.g = a.g div 2 + b.g div 2
  c.b = a.b div 2 + b.b div 2
  c.a = a.a div 2 + b.a div 2
  return c
