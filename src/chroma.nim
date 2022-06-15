##
## **Everything you want to do with colors.**
##

import chroma/names, chroma/colortypes, chroma/distance, chroma/transformations,
    chroma/temperature, hashes, strutils, tables
export colortypes, distance, transformations, temperature

proc toHex(a: float32): string {.inline.} = toHex(int(a))

proc `$`*(c: Color): string =
  ## Returns colors as "(r, g, b, a)".
  "(" & $c.r & ", " & $c.g & ", " & $c.b & ", " & $c.a & ")"

func hash*(c: Color): Hash =
  ## Hashes a Color - used in tables.
  hash((c.r, c.g, c.b, c.a))

func hash*(c: ColorRGB): Hash =
  ## Hashes a ColorRGB - used in tables.
  hash((c.r, c.g, c.b))

func hash*(c: ColorRGBA): Hash =
  ## Hashes a ColorRGB - used in tables.
  hash((c.r, c.g, c.b, c.a))

func hash*(c: ColorCMY): Hash =
  ## Hashes a ColorCMY - used in tables.
  hash((c.m, c.y, c.y))

func hash*(c: ColorCMYK): Hash =
  ## Hashes a ColorCMYK - used in tables.
  hash((c.m, c.y, c.y, c.k))

func hash*(c: ColorHSL): Hash =
  ## Hashes a ColorHSL - used in tables.
  hash((c.h, c.s, c.l))

func hash*(c: ColorHSV): Hash =
  ## Hashes a ColorHSV - used in tables.
  hash((c.h, c.s, c.v))

func hash*(c: ColorYUV): Hash =
  ## Hashes a ColorYUV - used in tables.
  hash((c.y, c.u, c.v))

func hash*(c: ColorXYZ): Hash =
  ## Hashes a ColorXYZ - used in tables.
  hash((c.x, c.y, c.z))

func hash*(c: ColorLAB): Hash =
  ## Hashes a ColorLAB - used in tables.
  hash((c.l, c.a, c.b))

func hash*(c: ColorPolarLAB): Hash =
  ## Hashes a ColorPolarLAB - used in tables.
  hash((c.l, c.c, c.h))

func hash*(c: ColorLUV): Hash =
  ## Hashes a ColorLUV - used in tables.
  hash((c.l, c.u, c.v))

func hash*(c: ColorPolarLUV): Hash =
  ## Hashes a ColorPolarLUV - used in tables.
  hash((c.h, c.c, c.l))

func hash*(c: ColorOklab): Hash =
  ## Hashes a ColorOklab - used in tables.
  hash((c.L, c.a, c.b))

func hash*(c: ColorPolarOklab): Hash =
  ## Hashes a ColorOklab - used in tables.
  hash((c.L, c.C, c.h))

proc almostEqual*(a, b: Color, ep = 0.01): bool =
  ## Returns true if colors are close
  if abs(a.r - b.r) > ep: return false
  if abs(a.g - b.g) > ep: return false
  if abs(a.b - b.b) > ep: return false
  return true

proc c2n(hex: string, i: int): int =
  ## Format int as a two diget HEX.
  let c = ord(hex[i])
  case c
  of ord('0') .. ord('9'): return c - ord('0')
  of ord('a') .. ord('f'): return 10 + c - ord('a')
  of ord('A') .. ord('F'): return 10 + c - ord('A')
  else:
    raise newException(InvalidColor, "format is not hex")

proc parseHex*(hex: string): Color =
  ## Parses colors like:
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
  template pair(n: float32): string =
    toHex(n*255)[^2..^1]
  pair(c.r) & pair(c.g) & pair(c.b)

proc parseHexAlpha*(hex: string): Color =
  ## Parses colors like:
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
  template pair(n: float32): string =
    toHex(n*255)[^2..^1]
  pair(c.r) & pair(c.g) & pair(c.b) & pair(c.a)

proc parseHtmlHex*(hex: string): Color =
  ## Parses colors with leading '#' like::
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
  '#' & c.toHex()

proc parseHtmlHexTiny*(hex: string): Color =
  ## Parses colors with leading '#' and 3 hex numbers like::
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
  ## Parses colors in html's rgb format:
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
  ## Parses colors in html's rgb format:
  ## * red -> rgb(255, 0, 0)
  ## * blue -> rgb(0,0,255)
  ## * white -> rgb(255,255,255)
  "rgb(" &
    $int(c.r * 255) & ", " &
    $int(c.g * 255) & ", " &
    $int(c.b * 255) &
  ")"

proc parseHtmlRgba*(text: string): Color =
  ## Parses colors in html's rgba format:
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
  ## Parses colors in html's rgb format:
  ## * red -> rgb(255, 0, 0)
  ## * blue -> rgb(0,0,255)
  ## * white -> rgb(255,255,255)
  "rgba(" &
    $int(c.r * 255) & ", " &
    $int(c.g * 255) & ", " &
    $int(c.b * 255) & ", " &
    $c.a &
  ")"

proc parseHtmlName*(text: string): Color =
  ## Parses HTML color as as a name:
  ## * "red"
  ## * "blue"
  ## * "white"
  ## * "amber"
  ## * "Lavender Gray"
  let lowerName = text.toLowerAscii()
  if lowerName in colorNames:
    return parseHex(colorNames[lowerName])
  else:
    raise newException(InvalidColor, "Not a valid color name: " & text)

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
      raise newException(InvalidColor, "HTML color invalid: " & colorText)
  if text.len > 4 and text[0..3] == "rgba":
    return parseHtmlRgba(text)
  if text.len > 3 and text[0..2] == "rgb":
    return parseHtmlRgb(text)
  parseHtmlName(text)

# Color Functions

proc lighten*(color: Color, amount: float32): Color =
  ## Lightens the color by amount 0-1.
  var hsl = color.hsl()
  hsl.l += 100 * amount
  hsl.l = clamp(hsl.l, 0, 100)
  result = color(hsl)
  result.a = color.a

proc darken*(color: Color, amount: float32): Color =
  ## Darkens the color by amount 0-1.
  color.lighten(-amount)

proc saturate*(color: Color, amount: float32): Color =
  ## Saturates (makes brighter) the color by amount 0-1.
  var hsl = color.hsl()
  hsl.s += 100 * amount
  hsl.s = clamp(hsl.s, 0, 100)
  result = color(hsl)
  result.a = color.a

proc desaturate*(color: Color, amount: float32): Color =
  ## Desaturate (makes grayer) the color by amount 0-1.
  color.saturate(-amount)

proc spin*(color: Color, degrees: float32): Color =
  ## Rotates the hue of the color by degrees (0-360).
  var hsl = color.hsl()
  hsl.h += degrees
  if hsl.h < 0: hsl.h += 360
  if hsl.h >= 360: hsl.h -= 360
  result = color(hsl)
  result.a = color.a

proc mix*(a, b: Color): Color =
  ## Mixes two Color colors together using simple average.
  result.r = (a.r + b.r) / 2.0
  result.g = (a.g + b.g) / 2.0
  result.b = (a.b + b.b) / 2.0
  result.a = (a.a + b.a) / 2.0

proc lerp(a, b, v: float32): float32 =
  a * (1.0 - v) + b * v

proc mix*(a, b: Color, v: float32): Color =
  ## Mixes two Color colors together using simple lerp.
  result.r = lerp(a.r, b.r, v)
  result.g = lerp(a.g, b.g, v)
  result.b = lerp(a.b, b.b, v)
  result.a = lerp(a.a, b.a, v)

proc mixCMYK*(colorA, colorB: Color): Color =
  ## Mixes two colors together using CMYK.
  let
    a = colorA.cmyk
    b = colorB.cmyk
  var c: ColorCMYK
  c.c = (a.c + b.c) / 2
  c.m = (a.m + b.m) / 2
  c.y = (a.y + b.y) / 2
  c.k = (a.k + b.k) / 2
  c.color

proc mix*(a, b: ColorRGB): ColorRGB =
  ## Mixes two ColorRGB colors together using simple average.
  result.r = a.r div 2 + b.r div 2
  result.g = a.g div 2 + b.g div 2
  result.b = a.b div 2 + b.b div 2

proc mix*(a, b: ColorRGBA): ColorRGBA =
  ## Mixes two ColorRGBA colors together using simple average.
  result.r = a.r div 2 + b.r div 2
  result.g = a.g div 2 + b.g div 2
  result.b = a.b div 2 + b.b div 2
  result.a = a.a div 2 + b.a div 2

func distance*(c1, c2: SomeColor): float32 =
  ## A distance function based on CIEDE2000 color difference formula
  deltaE00(c1.to(ColorLAB), c2.to(ColorLAB))
