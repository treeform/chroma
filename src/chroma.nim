##
## **Everything you want to do with colors.**
##

import strutils, math, tables, hashes
import chroma/names

# utility functions
proc min3(a, b, c: float32): float32 = min(a, min(b, c))
proc max3(a, b, c: float32): float32 = max(a, max(b, c))
proc clamp(n, a, b: float32): float32 = min(max(a, n), b)
proc toHex(a: float32): string = toHex(int(a))

type
  Color* = object
    ## Main color type, float32 points
    r*: float32 ## red (0-1)
    g*: float32 ## green (0-1)
    b*: float32 ## blue (0-1)
    a*: float32 ## alpha (0-1, 0 is fully transparent)

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
  result.r = float32(c.r) / 255
  result.g = float32(c.g) / 255
  result.b = float32(c.b) / 255
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
  result.r = float32(c.r) / 255
  result.g = float32(c.g) / 255
  result.b = float32(c.b) / 255
  result.a = float32(c.a) / 255


# Color Space: cmy
type
  ColorCMY* = object
    ## CMY colors are reverse of rgb and as 100%
    c*: float32 ## Cyan 0 to 100
    m*: float32 ## Magenta 0 to 100
    y*: float32 ## Yellow 0 to 100

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
    c*: float32 ## Cyan 0 to 1
    m*: float32 ## Magenta 0 to 1
    y*: float32 ## Yellow 0 to 1
    k*: float32 ## Black 0 to 1

proc cmyk*(c: Color): ColorCMYK =
  ## convert Color to ColorCMYK
  let k = min3(1 - c.r, 1 - c.g, 1 - c.b)
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
    h*: float32 ## hue 0 to 360
    s*: float32 ## saturation 0 to 100
    l*: float32 ## lightness 0 to 100

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
  var t1, t2, t3: float32
  if s == 0.0:
    return color(l, l, l)
  if l < 0.5:
    t2 = l * (1 + s)
  else:
    t2 = l + s - l * s
  t1 = 2 * l - t2

  var rgb: array[3, float32]
  for i in 0..2:
    t3 = h + 1.0 / 3.0 * - (float32(i) - 1.0)
    if t3 < 0:
      t3 += 1
    elif t3 > 1:
      t3 -= 1

    var val: float32
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

func fixupColor[T: int | float32](r, g, b: var T): bool =
  ## performs a fixup of the given r, g, b values and returnes whether
  ## any of the values was modified.
  ## This func works on integers or floats. It is only used within the
  ## conversion of `Color -> ColorHCL` (on integers) and `ColorHCL -> Color`
  ## (on floats).
  template fixC(c: untyped): untyped =
    if c < T(0):
      c = T(0)
      result = true
    when T is int:
      if c > 255:
        c = 255
        result = true
    else:
      if c > 1.0:
        c = 1.0
        result = true
  fixC(r)
  fixC(g)
  fixC(b)

func fixupColor(c: var Color): bool {.discardable.} = fixupColor(c.r, c.g, c.b)

proc RGB_to_HSL(c: Color): ColorHSL = hsl(c)
proc HSL_to_RGB(c: ColorHSL): Color =
  result = color(c)
  result.a = 1.0
  fixupColor(result)



type
  ColorXYZ* = object
    x*: float32
    y*: float32
    z*: float32

  ColorLAB* = object
    l: float32
    a: float32
    b: float32

  ColorPolarLAB* = object # not to be confused with ColorPolarLUV == ColorHCL!
    l: float32
    c: float32
    h: float32

const
  WhiteX = 95.047
  WhiteY = 100.000
  WhiteZ = 108.883

##  ----- CIE-XYZ <-> Device independent RGB -----
##
##   R, G, and B give the levels of red, green and blue as values
##   in the interval [0,1].  X, Y and Z give the CIE chromaticies.
##   XN, YN, ZN gives the chromaticity of the white point.
##
##

func RGB_to_XYZ*(c: Color): ColorXYZ =
  result.x = WhiteY * (0.412453 * c.r + 0.35758 * c.g + 0.180423 * c.b)
  result.y = WhiteY * (0.212671 * c.r + 0.71516 * c.g + 0.072169 * c.b)
  result.z = WhiteY * (0.019334 * c.r + 0.119193 * c.g + 0.950227 * c.b)

proc XYZ_to_RGB*(c: ColorXYZ): Color =
  result.r = (3.240479 * c.x - 1.53715 * c.y - 0.498535 * c.z) / WhiteY
  result.g = (-(0.969256 * c.x) + 1.875992 * c.y + 0.041556 * c.z) / WhiteY
  result.b = (0.055648 * c.x - 0.204043 * c.y + 1.057311 * c.z) / WhiteY
  result.fixupColor
  result.a = 1.0

var kappa*: cdouble = 24389.0 / 27.0

##  Often approximated as 0.08856

var epsilon*: cdouble = 216.0 / 24389.0

##  Also, instead of the oft-used approximation 7.787, below uses
##    (kappa / 116)

proc LAB_to_XYZ*(c: ColorLAB): ColorXYZ =
  var
    fx: float
    fy: float
    fz: float
  if c.l <= 0:
    result.y = 0.0
  elif c.l <= 8.0:
    result.y = c.l * WhiteY / kappa
  elif c.l <= 100:
    result.y = WhiteY * pow((c.l + 16.0) / 116.0, 3.0)
  else:
    result.y = WhiteY
  if result.y <= epsilon * WhiteY:
    fy = (kappa / 116.0) * result.y / WhiteY + 16.0 / 116.0
  else:
    fy = pow(result.y / WhiteY, 1.0 / 3.0)
  fx = fy + (c.a / 500.0)
  if pow(fx, 3.0) <= epsilon:
    result.x = WhiteX * (fx - 16.0 / 116.0) / (kappa / 116.0)
  else:
    result.x = WhiteX * pow(fx, 3.0)
  fz = fy - (c.b / 200.0)
  if pow(fz, 3.0) <= epsilon:
    result.z = WhiteZ * (fz - 16.0 / 116.0) / (kappa / 116.0)
  else:
    result.z = WhiteZ * pow(fz, 3.0)

proc f*(t: float): float =
  result = if t > epsilon:
             pow(t, 1.0 / 3.0)
           else:
             (kappa / 116.0) * t + 16.0 / 116.0

proc XYZ_to_LAB*(c: ColorXYZ): ColorLAB =
  var
    xr: float
    yr: float
    zr: float
    xt: float
    yt: float
    zt: float
  xr = c.x / WhiteX
  yr = c.y / WhiteY
  zr = c.z / WhiteZ
  if yr > epsilon:
    result.l = 116.0 * pow(yr, 1.0 / 3.0) - 16.0
  else:
    result.l = kappa * yr
  xt = f(xr)
  yt = f(yr)
  zt = f(zr)
  result.a = 500.0 * (xt - yt)
  result.b = 200.0 * (yt - zt)

proc LAB_to_polarLAB*(c: ColorLAB): ColorPolarLAB =
  var vH: float
  vH = radToDeg(arctan2(c.b, c.a))
  while vH > 360.0:
    vh = vh - 360.0
  while vH < 0.0:
    vH = vH + 360.0
  result.l = c.l
  result.c = sqrt(c.a * c.a + c.b * c.b)
  result.h = vH

proc polarLAB_to_LAB*(c: ColorPolarLab): ColorLAB =
  result.l = c.l
  result.a = cos(degToRad(c.h)) * c.c
  result.b = sin(degToRad(c.h)) * c.c

# Taken straight from R's grDevices module color.c:
# https://svn.r-project.org/R/trunk/src/library/grDevices/src/colors.c
# or mirror on GitHub with marked lines:
# https://github.com/wch/r-source/blob/trunk/src/library/grDevices/src/colors.c#L273-L309
# Color Space: HCL
type
  ColorHCL* = object
    h*: float32 ## hue
    c*: float32 ## chroma
    l*: float32 ## luminance

  ColorPolarLUV* = ColorHCL

func gtrans(u: float32): float32 =
  # Standard CRT Gamma
  const GAMMA = 2.4
  if u > 0.00304:
    result = 1.055 * pow(u, (1.0 / GAMMA)) - 0.055
  else:
    result = 12.92 * u

proc color*(c: ColorHCL): Color =
  ## convert ColorHCL to Color
  if c.l <= 0:
    return color(0.0, 0.0, 0.0)

  # Step 1 : Convert to CIE-LUV
  const
    WHITE_Y = 100.000'f32
    WHITE_u = 0.1978398
    WHITE_v = 0.4683363
  let
    h = c.h * PI / 180.0
    L = c.l
    U = c.c * cos(h)
    V = c.c * sin(h)
  var
    X: float32
    Y: float32
    Z: float32
    u: float32
    v: float32

  # Step 2 : Convert to CIE-XYZ */
  if L <= 0 and U == 0 and V == 0:
    X = 0
    Y = 0
    Z = 0
  else:
    Y = if L > 7.999592:
          WHITE_Y * pow((L + 16)/116, 3)
        else:
          L / 903.3
    u = U / (13.0 * L) + WHITE_u
    v = V / (13.0 * L) + WHITE_v
    X =  9.0 * Y * u / (4 * v)
    Z =  - X / 3 - 5 * Y + 3 * Y / v

  # Step 4 : CIE-XYZ to sRGB */
  result.r = gtrans(( 3.240479 * X - 1.537150 * Y - 0.498535 * Z) / WHITE_Y)
  result.g = gtrans((-0.969256 * X + 1.875992 * Y + 0.041556 * Z) / WHITE_Y)
  result.b = gtrans(( 0.055648 * X - 0.204043 * Y + 1.057311 * Z) / WHITE_Y)
  result.a = 1.0
  # now possibly fix the colors received fro gtrans. Some may be smaller than
  # 0.0, others larger than 1.0
  discard fixupColor(result.r, result.g, result.b)

#proc hcl*(c: ColorHCL): Color =
#  const
#    Y0 = 100
#    gamma = 3.0 # allowed in 1 <= gamma <= 31
#  let minRGB = min(c.r, c.g, c.b)
#  let maxRGB = max(c.r, c.g, c.b)
#  var alpha = 0.0
#  if maxRGB > 0.0:
#    alpha = minRGB / maxRGB / Y0
#  else:
#    alpha = 1.0

#proc hcl*(c: Color): ColorHCL =
#  ## convert Color to ColorHCL
#  var
#    H, C, L, A, r, g, g: float
#    nh, nc, nl, max, i, ir, ig, ib: int
#    na = 1
#    fixup = false
#
#  if c.a == 0.0:
#    H = h
#      H = REAL(h)[i % nh];
#      C = REAL(c)[i % nc];
#      L = REAL(l)[i % nl];
#      if (R_FINITE(H) && R_FINITE(C) && R_FINITE(L)) {
#          if (L < 0 || L > WHITE_Y || C < 0) error(_("invalid hcl color"));
#          hcl2rgb(H, C, L, &r, &g, &b);
#          ir = (int) (255 * r + .5);
#          ig = (int) (255 * g + .5);
#          ib = (int) (255 * b + .5);
#          if (FixupColor(&ir, &ig, &ib) && !fixup)
#              SET_STRING_ELT(ans, i, NA_STRING);
#          else
#              SET_STRING_ELT(ans, i, mkChar(RGB2rgb(ir, ig, ib)));
#      } else SET_STRING_ELT(ans, i, NA_STRING);
#  else:
#      for (i = 0; i < max; i++) {
#          H = REAL(h)[i % nh];
#          C = REAL(c)[i % nc];
#          L = REAL(l)[i % nl];
#          A = REAL(a)[i % na];
#          if (!R_FINITE(A)) A = 1;
#          if (R_FINITE(H) && R_FINITE(C) && R_FINITE(L)) {
#              if (L < 0 || L > WHITE_Y || C < 0 || A < 0 || A > 1)
#                  error(_("invalid hcl color"));
#              hcl2rgb(H, C, L, &r, &g, &b);
#              ir = (int) (255 * r + .5);
#              ig = (int) (255 * g + .5);
#              ib = (int) (255 * b + .5);
#              if (FixupColor(&ir, &ig, &ib) && !fixup)
#                  SET_STRING_ELT(ans, i, NA_STRING);
#              else
#                  SET_STRING_ELT(ans, i, mkChar(RGBA2rgb(ir, ig, ib,
#                                                         ScaleAlpha(A))));
#          } else SET_STRING_ELT(ans, i, NA_STRING);
#      }
#  }
#  UNPROTECT(5);
#  return ans;

#proc




# Color Space: HSV
type
  ColorHSV* = object
    ## HSV models the way paints of different colors mix together
    h*: float32 ## hue 0 to 360
    s*: float32 ## saturation 0 to 100
    v*: float32 ## value 0 to 100


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

# aliases for clarity
proc RGB_to_HSV*(c: Color): ColorHSV = hsv(c)
proc HSV_to_RGB*(c: ColorHSV): Color =
  result = color(c)
  result.fixupColor
  result.a = 1.0

# Color Space: YUV
type
  ColorYUV* = object
    ## YUV origially a television color format, still used in digital movies
    y*: float32 ## 0 to 1
    u*: float32 ## -0.5 to 0.5
    v*: float32 ## -0.5 to 0.5


proc yuv*(c: Color): ColorYUV =
  ## convert Color to ColorYUV
  result.y = (c.r * 0.299) + (c.g * 0.587) + (c.b * 0.114)
  result.u = (c.r * -0.14713) + (c.g * -0.28886) + (c.b * 0.436)
  result.v = (c.r * 0.615) + (c.g * -0.51499) + (c.b * -0.10001)


proc color*(c: ColorYUV): Color =
  ## convert ColorYUV to Color
  result.r = (c.y * 1) + (c.u * 0) + (c.v * 1.13983);
  result.g = (c.y * 1) + (c.u * -0.39465) + (c.v * -0.58060);
  result.b = (c.y * 1) + (c.u * 2.02311) + (c.v * 0);

  result.r = clamp(result.r, 0, 1)
  result.g = clamp(result.g, 0, 1)
  result.b = clamp(result.b, 0, 1)

##
##  rgb all in [0,1]
##  h in [0, 360], ls in [0,1]
##
##  From:
##  http://wiki.beyondunreal.com/wiki/RGB_To_HLS_Conversion
##

#type
#  ColorHLS* = object
#    h: float32
#    l: float32
#    s: float32
#
proc RGB_to_HLS*(c: Color): ColorHSL =
  var
    min: float
    max: float
  min = min3(c.r, c.g, c.b)
  max = max3(c.r, c.g, c.b)
  result.l = (max + min) / 2.0
  if max != min:
    if result.l < 0.5:
      result.s = (max - min) / (max + min)
    if result.l >= 0.5:
      result.s = (max - min) / (2.0 - max - min)
    if c.r == max:
      result.h = (c.g - c.b) / (max - min)
    if c.g == max:
      result.h = 2.0 + (c.b - c.r) / (max - min)
    if c.b == max:
      result.h = 4.0 + (c.r - c.g) / (max - min)
    result.h = result.h * 60.0
    if result.h < 0.0:
      result.h = result.h + 360.0
    if result.h > 360.0:
      result.h = result.h - 360.0
  else:
    result.s = 0.0
    result.h = 0
    #when defined(MONO):
    #  result.h = NA_REAL
    #else:
    #  result.h = 0

proc qtrans*(q1: float; q2: float; hue: float): float =
  var mhue = hue
  if mhue > 360.0:
    mhue = mhue - 360.0
  if mhue < 0.0:
    mhue = mhue + 360.0
  if mhue < 60.0:
    result = q1 + (q2 - q1) * mhue / 60.0
  elif mhue < 180.0:
    result = q2
  elif mhue < 240.0:
    result = q1 + (q2 - q1) * (240.0 - mhue) / 60.0
  else:
    result = q1

proc HLS_to_RGB*(c: ColorHSL): Color =
  var p1: float
  var p2: float
  if c.l <= 0.5:
    p2 = c.l * (1 + c.s)
  else:
    p2 = c.l + c.s - (c.l * c.s)
  p1 = 2 * c.l - p2
  if c.s == 0:
    result.r = c.l
    result.g = c.l
    result.b = c.l
  else:
    result.r = qtrans(p1, p2, c.h + 120.0)
    result.g = qtrans(p1, p2, c.h)
    result.b = qtrans(p1, p2, c.h - 120.0)
  result.fixupColor
  result.a = 1.0

##  ----- CIE-XYZ <-> CIE-LUV -----
type
  ColorLUV* = object
    l: float32
    u: float32
    v: float32

proc XYZ_to_uv*(c: ColorXYZ): tuple[u, v: float32] =
  var
    t: float
    x: float
    y: float
  t = c.x + c.y + c.z
  if t == 0.0:
    x = 0.0
    y = 0.0
  else:
    x = c.x / t
    y = c.y / t
  result.u = 2.0 * x / (6.0 * y - x + 1.5)
  result.v = 4.5 * y / (6.0 * y - x + 1.5)

proc XYZ_to_LUV*(c: ColorXYZ): ColorLUV =
  var
    u: float
    v: float
    uN: float
    vN: float
    y: float
  (u, v) = XYZ_to_uv(c)
  (uN, vN) = XYZ_to_uv(ColorXYZ(x: WhiteX, y: WhiteY, z: WhiteZ))
  y = c.y / WhiteY
  result.l = if (y > epsilon): 116.0 * pow(y, 1.0 / 3.0) - 16 else: kappa * y
  result.u = 13.0 * result.l * (u - uN)
  result.v = 13.0 * result.l * (v - vN)

proc LUV_to_XYZ*(c: ColorLUV): ColorXYZ =
  var
    u: float
    v: float
    uN: float
    vN: float
  if c.l <= 0.0 and c.u == 0.0 and c.v == 0.0:
    result.x = 0.0
    result.y = 0.0
    result.z = 0.0
  else:
    ##  8 = kappa*epsilon
    result.y = WhiteY * (if (c.l > 8): pow((c.l + 16.0) / 116.0, 3.0) else: c.l / kappa)
    (uN, vN) = XYZ_to_uv(ColorXYZ(x: WhiteX, y: WhiteY, z: WhiteZ))
    ##  Avoid division by zero if L = 0
    if c.l == 0.0:
      u = uN
      v = vN
    else:
      u = c.u / (13.0 * c.l) + uN
      v = c.v / (13.0 * c.l) + vN
    result.x = 9.0 * result.y * c.u / (4.0 * v)
    result.z = -result.x / 3.0 - 5.0 * result.y + 3.0 * result.y / v

proc LUV_to_polarLUV*(c: ColorLUV): ColorPolarLUV =
  result.l = c.l
  result.c = sqrt(c.u * c.u + c.v * c.v)
  result.h = radToDeg(arctan2(c.v, c.u))
  while result.h > 360.0:
    result.h = result.h - 360.0
  while result.h < 0.0:
    result.h = result.h + 360.0

proc polarLUV_to_LUV*(c: ColorPolarLUV): ColorLUV =
  let hrad = degToRad(c.h)
  result.l = c.l
  result.u = c.c * cos(hrad)
  result.v = c.c * sin(hrad)

type
  SomeColor = Color | ColorHSL | ColorHSV | ColorLAB | ColorPolarLAB | ColorLUV | ColorPolarLUV | ColorXYZ

proc asRGB[T: SomeColor](c: T): Color =
  when T is Color:
    result = c
  elif T is ColorHSL:
    result = c.HLS_to_RGB
  elif T is ColorHSV:
    result = c.HSV_to_RGB
  elif T is ColorXYZ:
    result = c.XYZ_to_RGB
  elif T is ColorLAB | ColorPolarLAB | ColorLUV | ColorPolarLUV:
    result = c.asXYZ.XYZ_to_RGB

proc asHSL[T: SomeColor](c: T): ColorHSL =
  when T is Color:
    result = c.RGB_to_HSL
  elif T is ColorHSL:
    result = c
  else:
    result = c.asRGB.RGB_to_HSL

proc asHSV[T: SomeColor](c: T): ColorHSV =
  when T is Color:
    result = c.RGB_to_HSV
  elif T is ColorHSV:
    result = c
  else:
    result = c.asRGB.RGB_to_HSV

proc asXYZ[T: SomeColor](c: T): ColorXYZ =
  when T is Color:
    result = c.RGB_to_XYZ
  elif T is ColorHSL:
    result = c.asRGB.RGB_to_XYZ
  elif T is ColorHSV:
    result = c.asRGB.RGB_to_XYZ
  elif T is ColorXYZ:
    result = c
  elif T is ColorLAB:
    result = c.LAB_to_XYZ
  elif T is ColorPolarLAB:
    result = c.asLAB.LAB_to_XYZ
  elif T is ColorLUV:
    result = c.LUV_to_XYZ
  elif T is ColorPolarLUV:
    result = c.asLUV.LUV_to_XYZ

proc asLAB[T: SomeColor](c: T): ColorLAB =
  when T is ColorXYZ:
    result = c.XYZ_to_LAB
  elif T is ColorLAB:
    result = c
  elif T is ColorPolarLAB:
    result = c.polarLAB_to_LAB
  else:
    result = c.asXYZ.XYZ_to_LAB

proc asPolarLAB[T: SomeColor](c: T): ColorPolarLAB =
  when T is ColorLab:
    result = c.LAB_to_polarLAB
  elif T is ColorPolarLAB:
    result = c
  else:
    result = c.asLAB.LAB_to_polarLAB

proc asLUV[T: SomeColor](c: T): ColorLUV =
  when T is ColorXYZ:
    result = c.XYZ_to_LUV
  elif T is ColorLUV:
    result = c
  elif T is ColorPolarLUV:
    result = c.polarLUV_to_LUV
  else:
    result = c.asXYZ.XYZ_to_LUV

import typetraits

proc asPolarLUV[T: SomeColor](c: T): ColorPolarLUV =
  when T is ColorLab:
    result = c.LUV_to_polarLUV
  elif T is ColorPolarLUV:
    result = c
  else:
    result = c.asLUV.LUV_to_polarLUV

proc to*[T: SomeColor](c: T, toColor: typedesc): toColor =
  when toColor is Color:
    result = c.asRGB
  elif toColor is ColorHSL:
    result = c.asHSL
  elif toColor is ColorHSV:
    result = c.asHSV
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