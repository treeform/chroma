import strutils, math, tables
import chroma/names

# utility functions
proc min3(a, b, c: float): float = min(a, min(b, c))
proc max3(a, b, c: float): float = max(a, max(b, c))
proc clamp(n, a, b: float): float = min(max(a, n), b)


type
  Color* = object
    ## Main color type, float points
    r*: float ## red (0-1)
    g*: float ## green (0-1)
    b*: float ## blue (0-1)
    a*: float ## alpha (0-1, 0 is fully transparent)

  InvalidColor* = object of Exception


proc color*(r, g, b, a = 1.0): Color =
  ## Creates from floats like:
  ## * color(1,0,0) -> red
  ## * color(0,1,0) -> green
  ## * color(0,0,1) -> blue
  ## * color(0,0,0,1) -> opaque  black
  ## * color(0,0,0,0) -> transparent black
  result.r = r
  result.g = g
  result.b = b
  result.a = a


proc `$`*(c: Color): string =
  ## returns colors as "(r, g, b, a)"
  "(" & $c.r & ", " & $c.g & ", " & $c.b & ", " & $c.a & ")"


proc almostEqual*(a, b: Color, ep = 0.01): bool =
  ## Returns true if colors are close
  if abs(a.r - b.r) > ep: return false
  if abs(a.g - b.g) > ep: return false
  if abs(a.b - b.b) > ep: return false
  return true


proc c2n(hex: string, i: int): int =
  var c = ord(hex[i])
  if c >= ord('0') and c <= ord('9'):
    return c - ord('0')
  elif c >= ord('a') and c <= ord('f'):
    return 10 + c - ord('a')
  elif c >= ord('A') and c <= ord('F'):
    return 10 + c - ord('A')
  else:
    raise newException(InvalidColor, "format is not hex")


proc parseHex*(hex: string): Color =
  ## parse colors like
  ## * FF0000 -> red
  ## * 0000FF -> blue
  ## * FFFFFF -> white
  assert hex.len == 6
  result.r = float(c2n(hex, 0) * 16 + c2n(hex, 1)) / 255
  result.g = float(c2n(hex, 2) * 16 + c2n(hex, 3)) / 255
  result.b = float(c2n(hex, 4) * 16 + c2n(hex, 5)) / 255
  result.a = 1.0


proc toHex*(c: Color): string =
  ## Formats color as hex (upper case):
  ## * red -> FF0000
  ## * blue -> 0000FF
  ## * white -> FFFFFF
  proc pair(n: float): string =
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
  result.r = float(c2n(hex, 0) * 16 + c2n(hex, 1)) / 255
  result.g = float(c2n(hex, 2) * 16 + c2n(hex, 3)) / 255
  result.b = float(c2n(hex, 4) * 16 + c2n(hex, 5)) / 255
  result.a = float(c2n(hex, 6) * 16 + c2n(hex, 7)) / 255


proc toHexAlpha*(c: Color): string =
  ## Formats color as hex (upper case):
  ## * red -> FF0000FF
  ## * blue -> 0000FFFF
  ## * white -> FFFFFFFF
  ## * opaque  black -> 000000FF
  ## * transparent black -> 00000000
  proc pair(n: float): string =
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
  result.r = float(c2n(hex, 1)) / 15
  result.g = float(c2n(hex, 2)) / 15
  result.b = float(c2n(hex, 3)) / 15
  result.a = 1.0


proc toHtmlHexTiny*(c: Color): string =
  ## Formats color as HTML 3 hex numbers (upper case):
  ## * red -> #F00
  ## * blue -> #00F
  ## * white -> #FFF
  proc pair(n: float): string =
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
  var inner = text[4..^2].replace(" ", "")
  var arr = inner.split(',')
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
  var inner = text[5..^2].replace(" ", "")
  var arr = inner.split(',')
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


# Color Space: rgb
type
  ColorRGB* = object
    ## Color stored as 3 uint8s
    r*: uint8 ## Red 0-255
    g*: uint8 ## Green 0-255
    b*: uint8 ## Blue 0-255


proc rgb*(c: Color): ColorRGB =
  ## Convert Color to ColorRGB
  result.r = uint8(c.r * 255)
  result.g = uint8(c.g * 255)
  result.b = uint8(c.b * 255)


proc rgb*(r, g, b: uint8): ColorRGB =
  ## Creates ColorRGB from intergers in 0-255 range like:
  ## * rgb(255,0,0) -> red
  ## * rgb(0,255,0) -> green
  ## * rgb(0,0,255) -> blue
  result.r = r
  result.g = g
  result.b = b


proc color*(c: ColorRGB): Color =
  ## Convert ColorRGB to Color
  result.r = float(c.r) / 255
  result.g = float(c.g) / 255
  result.b = float(c.b) / 255
  result.a = 1.0


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


# Color Space: rgba
type
  ColorRGBA* = object
    ## Color stored as 4 uint8s
    r*: uint8 ## Red 0-255
    g*: uint8 ## Green 0-255
    b*: uint8 ## Blue 0-255
    a*: uint8 ## Alpha 0-255


proc rgba*(c: Color): ColorRGBA =
  ## Convert Color to ColorRGBA
  result.r = uint8(c.r * 255)
  result.g = uint8(c.g * 255)
  result.b = uint8(c.b * 255)
  result.a = uint8(c.a * 255)


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


proc color*(c: ColorRGBA): Color =
  ## Convert ColorRGBA to Color
  result.r = float(c.r) / 255
  result.g = float(c.g) / 255
  result.b = float(c.b) / 255
  result.a = float(c.a) / 255


# Color Space: cmy
type
  ColorCMY* = object
    ## CMY colors are reverse of rgb and as 100%
    c*: float ## Cyan 0 to 100
    m*: float ## Magenta 0 to 100
    y*: float ## Yellow 0 to 100

proc cmy*(c: Color): ColorCMY =
  ## convert Color to ColorCMY
  result.c = (1 - c.r) * 100
  result.m = (1 - c.g) * 100
  result.y = (1 - c.b) * 100


proc color*(c: ColorCMY): Color =
  ## convert ColorCMY to Color
  result.r = 1 - c.c / 100
  result.g = 1 - c.m / 100
  result.b = 1 - c.y / 100
  result.a = 1.0


# Color Space: cmyk
type
  ColorCMYK* = object
    ## CMYK colors are used in printing
    c*: float ## Cyan 0 to 1
    m*: float ## Magenta 0 to 1
    y*: float ## Yellow 0 to 1
    k*: float ## Black 0 to 1

proc cmyk*(c: Color): ColorCMYK =
  ## convert Color to ColorCMYK
  var k = min3(1 - c.r, 1 - c.g, 1 - c.b)
  result.k = k * 100
  if k != 1.0:
    result.c = (1 - c.r - k) / (1 - k) * 100
    result.m = (1 - c.g - k) / (1 - k) * 100
    result.y = (1 - c.b - k) / (1 - k) * 100


proc color*(color: ColorCMYK): Color =
  ## convert ColorCMYK to Color
  let
    k = color.k / 100
    c = color.c / 100
    m = color.m / 100
    y = color.y / 100
  result.r = 1 - min(1, c * (1 - k) + k)
  result.g = 1 - min(1, m * (1 - k) + k)
  result.b = 1 - min(1, y * (1 - k) + k)
  result.a = 1.0


# Color Space: HSL
type
  ColorHSL* = object
    ## HSL attempts to resemble more perceptual color models
    h*: float ## hue 0 to 360
    s*: float ## saturation 0 to 100
    l*: float ## lightness 0 to 100


proc hsl*(c: Color): ColorHSL =
  ## convert Color to ColorHSL
  let
    min = min3(c.r, c.g, c.b)
    max = max3(c.r, c.g, c.b)
    delta = max - min
  if max == min:
    result.h = 0.0
  elif c.r == max:
    result.h = (c.g - c.b) / delta
  elif c.g == max:
    result.h = 2 + (c.b - c.r) / delta
  elif c.b == max:
    result.h = 4 + (c.r - c.g) / delta

  result.h = min(result.h * 60, 360)
  if result.h < 0:
    result.h += 360

  result.l = (min + max) / 2

  if max == min:
    result.s = 0
  elif result.l <= 0.5:
    result.s = delta / (max + min)
  else:
    result.s = delta / (2 - max - min)

  result.s *= 100
  result.l *= 100


proc color*(c: ColorHSL): Color =
  ## convert ColorHSL to Color
  let
    h = c.h / 360
    s = c.s / 100
    l = c.l / 100
  var t1, t2, t3: float
  if s == 0.0:
    return color(l, l, l)
  if l < 0.5:
    t2 = l * (1 + s)
  else:
    t2 = l + s - l * s
  t1 = 2 * l - t2

  var rgb: array[3, float]
  for i in 0..2:
    t3 = h + 1.0 / 3.0 * - (float(i) - 1.0)
    if t3 < 0:
      t3 += 1
    elif t3 > 1:
      t3 -= 1

    var val: float
    if 6 * t3 < 1:
      val = t1 + (t2 - t1) * 6 * t3
    elif 2 * t3 < 1:
      val = t2
    elif 3 * t3 < 2:
      val = t1 + (t2 - t1) * (2 / 3 - t3) * 6
    else:
      val = t1

    rgb[i] = val
  result.r = rgb[0]
  result.g = rgb[1]
  result.b = rgb[2]
  result.a = 1.0


# Color Space: HSV
type
  ColorHSV* = object
    ## HSV models the way paints of different colors mix together
    h*: float ## hue 0 to 360
    s*: float ## saturation 0 to 100
    v*: float ## value 0 to 100


proc hsv*(c: Color): ColorHSV =
  ## convert Color to ColorHSV
  let
    min = min3(c.r, c.g, c.b)
    max = max3(c.r, c.g, c.b)
    delta = max - min

  if max == min:
    result.s = 0
  else:
    result.s = delta / max * 100

  if max == min:
    result.h = 0.0
  elif c.r == max:
    result.h = (c.g - c.b) / delta
  elif c.g == max:
    result.h = 2 + (c.b - c.r) / delta
  elif c.b == max:
    result.h = 4 + (c.r - c.g) / delta

  result.h = min(result.h * 60, 360)
  if result.h < 0:
    result.h += 360

  result.v = max * 100


proc color*(c: ColorHSV): Color =
  ## convert ColorHSV to Color
  let
    h = c.h / 60
    s = c.s / 100
    v = c.v / 100
    hi = floor(h) mod 6
    f = h - floor(h)
    p = v * (1 - s)
    q = v * (1 - (s * f))
    t = v * (1 - (s * (1 - f)))
  case hi:
    of 0:
      return color(v, t, p)
    of 1:
      return color(q, v, p)
    of 2:
      return color(p, v, t)
    of 3:
      return color(p, q, v)
    of 4:
      return color(t, p, v)
    of 5:
      return color(v, p, q)


# Color Space: YUV
type
  ColorYUV* = object
    ## YUV origially a television color format, still used in digital movies
    y*: float ## 0 to 1
    u*: float ## -0.5 to 0.5
    v*: float ## -0.5 to 0.5


proc yuv*(c: Color): ColorYUV =
  ## convert Color to ColorYUV
  result.y = (c.r * 0.299) + (c.g * 0.587) + (c.b * 0.114)
  result.u = (c.r * -0.14713) + (c.g * -0.28886) + (c.b * 0.436)
  result.v = (c.r * 0.615) + (c.g * -0.51499) + (c.b * -0.10001)


proc color*(c: ColorYUV): Color =
  ## convert ColorYUV to Color
  result.r = (c.y * 1) + (c.u *  0) + (c.v * 1.13983);
  result.g = (c.y * 1) + (c.u * -0.39465) + (c.v * -0.58060);
  result.b = (c.y * 1) + (c.u * 2.02311) + (c.v * 0);

  result.r = clamp(result.r, 0, 1)
  result.g = clamp(result.g, 0, 1)
  result.b = clamp(result.b, 0, 1)


# Color Functions

proc lighten*(color: Color, amount: float): Color =
  ## Lightens the color by amount 0-1
  var hsl = color.hsl()
  hsl.l += 100 * amount
  hsl.l = clamp(hsl.l, 0, 100)
  result = color(hsl)
  result.a = color.a


proc darken*(color: Color, amount: float): Color =
  ## Darkens the color by amount 0-1
  color.lighten(-amount)


proc saturate*(color: Color, amount: float): Color =
  ## Saturates (makes brighter) the color by amount 0-1
  var hsl = color.hsl()
  hsl.s += 100 * amount
  hsl.s = clamp(hsl.s, 0, 100)
  result = color(hsl)
  result.a = color.a


proc desaturate*(color: Color, amount: float): Color =
  ## Desaturate (makes grayer) the color by amount 0-1
  color.saturate(-amount)


proc spin*(color: Color, degrees: float): Color =
  ## Rotates the hue of the color by degrees (0-360)
  var hsl = color.hsl()
  hsl.h += degrees
  if hsl.h < 0: hsl.h += 360
  if hsl.h >= 360: hsl.h -= 360
  result = color(hsl)
  result.a = color.a


proc mix*(colorA, colorB: Color): Color =
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