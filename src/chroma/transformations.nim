## This file contains the "low level" transformations between different
## color spaces. The transformations to be used by the user are defined
## in `chroma.nim`.

## The lowest procs are the simple `*_to_*` procs. They are called
## by the `as*` procs for a more unified interface. The user facing
## proc `to` is defined in `chroma.nim` and makes use of the `as*` procs.

## Note, that the term `RGB` as used in the `*_to_*` procs refers to the
## main color object `Color`, not the explicit `ColorRGB` using `uint8` to
## represent the values!

## For the simple of `RGB_to_XXX`, a proc named `xxx` is defined in
## chroma.nim of signature
## `proc xxx(c: Color): ColorXXX`
## and a `color` proc for the inverse transformation:
## `proc color(c: ColorXXX): Color`.
## However, for some colorspaces those transformations are not implemneted,
## a transformation via some other colorspace is necessary.

## The code for the transformations of
## - LAB
## - LUV
## - PolarLAB
## - PolarLUV
## - XYZ
## were ported from the C code of the R colorspaces package, which is licensed
## under the 3-clause BSD license.
## - http://colorspace.r-forge.r-project.org/
## and link to a mirror of the C file:
## - https://github.com/cran/colorspace/blob/master/src/colorspace.c

import colortypes, math

################################################################################
###                          Code from chroma.nim                            ###
################################################################################

proc min3(a, b, c: float32): float32 = min(a, min(b, c))
proc max3(a, b, c: float32): float32 = max(a, max(b, c))

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
# overload working on `var Color`. It's `discardable`, because in our usage
# here we do not really care whether a value was modified.
func fixupColor(c: var Color): bool {.discardable.} = fixupColor(c.r, c.g, c.b)

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

proc RGB_to_RGB_type*(c: Color): ColorRGB =
  ## Convert Color to ColorRGB
  result.r = uint8(c.r * 255)
  result.g = uint8(c.g * 255)
  result.b = uint8(c.b * 255)

proc RGB_type_to_RGB*(c: ColorRGB): Color =
  ## Convert ColorRGB to Color
  result.r = float32(c.r) / 255
  result.g = float32(c.g) / 255
  result.b = float32(c.b) / 255
  result.a = 1.0

proc RGB_to_RGBA*(c: Color): ColorRGBA =
  ## Convert Color to ColorRGBA
  result.r = uint8(c.r * 255)
  result.g = uint8(c.g * 255)
  result.b = uint8(c.b * 255)
  result.a = uint8(c.a * 255)

proc RGBA_to_RGB*(c: ColorRGBA): Color =
  ## Convert ColorRGBA to Color
  result.r = float32(c.r) / 255
  result.g = float32(c.g) / 255
  result.b = float32(c.b) / 255
  result.a = float32(c.a) / 255

proc RGB_to_HSL*(c: Color): ColorHSL =
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

proc HSL_to_RGB*(c: ColorHSL): Color =
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
  fixupColor(result)
  result

proc RGB_to_HSV*(c: Color): ColorHSV =
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

proc HSV_to_RGB*(c: ColorHSV): Color =
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
      result = color(v, t, p)
    of 1:
      result = color(q, v, p)
    of 2:
      result = color(p, v, t)
    of 3:
      result = color(p, q, v)
    of 4:
      result = color(t, p, v)
    of 5:
      result = color(v, p, q)
  result.a = 1.0
  result.fixupColor

proc RGB_to_YUV*(c: Color): ColorYUV =
  ## convert Color to ColorYUV
  result.y = (c.r * 0.299) + (c.g * 0.587) + (c.b * 0.114)
  result.u = (c.r * -0.14713) + (c.g * -0.28886) + (c.b * 0.436)
  result.v = (c.r * 0.615) + (c.g * -0.51499) + (c.b * -0.10001)

proc YUV_to_RGB*(c: ColorYUV): Color =
  ## convert ColorYUV to Color
  result.r = (c.y * 1) + (c.u * 0) + (c.v * 1.13983)
  result.g = (c.y * 1) + (c.u * -0.39465) + (c.v * -0.58060)
  result.b = (c.y * 1) + (c.u * 2.02311) + (c.v * 0)

  result.r = clamp(result.r, 0, 1)
  result.g = clamp(result.g, 0, 1)
  result.b = clamp(result.b, 0, 1)
  result.a = 1.0

proc RGB_to_CMY*(c: Color): ColorCMY =
  ## convert Color to ColorCMY
  result.c = (1 - c.r) * 100.0
  result.m = (1 - c.g) * 100.0
  result.y = (1 - c.b) * 100.0

proc CMY_to_RGB*(c: ColorCMY): Color =
  ## convert ColorCMY to Color
  result.r = 1 - c.c / 100.0
  result.g = 1 - c.m / 100.0
  result.b = 1 - c.y / 100.0
  result.a = 1.0

proc RGB_to_CMYK*(c: Color): ColorCMYK =
  ## convert Color to ColorCMYK
  let k = min3(1 - c.r, 1 - c.g, 1 - c.b)
  result.k = k * 100.0
  if k != 1.0:
    result.c = (1 - c.r - k) / (1 - k) * 100.0
    result.m = (1 - c.g - k) / (1 - k) * 100.0
    result.y = (1 - c.b - k) / (1 - k) * 100.0

proc CMYK_to_RGB*(color: ColorCMYK): Color =
  ## convert ColorCMYK to Color
  let
    k = color.k / 100.0
    c = color.c / 100.0
    m = color.m / 100.0
    y = color.y / 100.0
  result.r = 1 - min(1, c * (1 - k) + k)
  result.g = 1 - min(1, m * (1 - k) + k)
  result.b = 1 - min(1, y * (1 - k) + k)
  result.a = 1.0

################################################################################
###                      Ported code from colorspaces                        ###
################################################################################

##  Copyright 2005, Ross Ihaka. All Rights Reserved.
##
##  Redistribution and use in source and binary forms, with or without
##  modification, are permitted provided that the following conditions
##  are met:
##
##     1. Redistributions of source code must retain the above copyright notice,
##        this list of conditions and the following disclaimer.
##
##     2. Redistributions in binary form must reproduce the above copyright
##        notice, this list of conditions and the following disclaimer in the
##        documentation and/or other materials provided with the distribution.
##
##     3. The name of the Ross Ihaka may not be used to endorse or promote
##        products derived from this software without specific prior written
##        permission.
##
##  THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS''
##  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
##  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
##  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ROSS IHAKA BE LIABLE FOR
##  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
##  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
##  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
##  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
##  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
##  IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
##  POSSIBILITY OF SUCH DAMAGE.

# The whitepoint used for the XYZ colorspace
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

proc ftrans(u, gamma: float32): float32 =
  if u > 0.03928:
    result = pow((u + 0.055) / 1.055, gamma)
  else:
    result = u / 12.92

func gtrans(u: float32): float32 =
  # Standard CRT Gamma
  const GAMMA = 2.4
  if u > 0.00304:
    result = 1.055 * pow(u, (1.0 / GAMMA)) - 0.055
  else:
    result = 12.92 * u

func RGB_to_XYZ*(c: Color): ColorXYZ =
  let
    r = ftrans(c.r, 2.4)
    g = ftrans(c.g, 2.4)
    b = ftrans(c.b, 2.4)
  result.x = WhiteY * (0.412453 * r + 0.35758 * g + 0.180423 * b)
  result.y = WhiteY * (0.212671 * r + 0.71516 * g + 0.072169 * b)
  result.z = WhiteY * (0.019334 * r + 0.119193 * g + 0.950227 * b)

proc XYZ_to_RGB*(c: ColorXYZ): Color =
  result.r = gtrans((3.240479 * c.x - 1.53715 * c.y - 0.498535 * c.z) / WhiteY)
  result.g = gtrans((-(0.969256 * c.x) + 1.875992 * c.y + 0.041556 * c.z) / WhiteY)
  result.b = gtrans((0.055648 * c.x - 0.204043 * c.y + 1.057311 * c.z) / WhiteY)
  result.fixupColor
  result.a = 1.0

const kappa*: cdouble = 24389.0 / 27.0

##  Often approximated as 0.08856

const epsilon*: cdouble = 216.0 / 24389.0

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
  result.l = if (y > epsilon): 116.0 * pow(y, 1.0 / 3.0) - 16.0 else: kappa * y
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
    if c.l > 8.0:
      result.y = WhiteY * pow((c.l + 16.0) / 116.0, 3.0)
    else:
      result.y = WhiteY * c.l / kappa
    (uN, vN) = XYZ_to_uv(ColorXYZ(x: WhiteX, y: WhiteY, z: WhiteZ))
    ##  Avoid division by zero if L = 0
    if c.l == 0.0:
      u = uN
      v = vN
    else:
      u = c.u / (13.0 * c.l) + uN
      v = c.v / (13.0 * c.l) + vN
    result.x = 9.0 * result.y * u / (4.0 * v)
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

################################################################################
###                  End of ported code from colorspaces                     ###
################################################################################

proc asRGB*[T: SomeColor](c: T): Color =
  when T is Color:
    result = c
  elif T is ColorRGB:
    result = c.RGB_type_to_RGB
  elif T is ColorRGBA:
    result = c.RGBA_to_RGB
  elif T is ColorHSL:
    result = c.HSL_to_RGB
  elif T is ColorHSV:
    result = c.HSV_to_RGB
  elif T is ColorYUV:
    result = c.YUV_to_RGB
  elif T is ColorCMYK:
    result = c.CMYK_to_RGB
  elif T is ColorCMY:
    result = c.CMY_to_RGB
  elif T is ColorXYZ:
    result = c.XYZ_to_RGB
  else:
    result = c.asXYZ.XYZ_to_RGB

proc asRGB_type*[T: SomeColor](c: T): ColorRGB =
  when T is Color:
    result = c.RGB_to_RGB_type
  elif T is ColorRGB:
    result = c
  else:
    result = c.asRGB.RGB_to_RGB_type

proc asRGBA*[T: SomeColor](c: T): ColorRGBA =
  when T is Color:
    result = c.RGB_to_RGBA
  elif T is ColorRGBA:
    result = c
  else:
    result = c.asRGB.RGB_to_RGBA

proc asHSL*[T: SomeColor](c: T): ColorHSL =
  when T is Color:
    result = c.RGB_to_HSL
  elif T is ColorHSL:
    result = c
  else:
    result = c.asRGB.RGB_to_HSL

proc asHSV*[T: SomeColor](c: T): ColorHSV =
  when T is Color:
    result = c.RGB_to_HSV
  elif T is ColorHSV:
    result = c
  else:
    result = c.asRGB.RGB_to_HSV

proc asYUV*[T: SomeColor](c: T): ColorYUV =
  when T is Color:
    result = c.RGB_to_YUV
  elif T is ColorYUV:
    result = c
  else:
    result = c.asRGB.RGB_to_YUV

proc asCMYK*[T: SomeColor](c: T): ColorCMYK =
  when T is Color:
    result = c.RGB_to_CMYK
  elif T is ColorCMYK:
    result = c
  else:
    result = c.asRGB.RGB_to_CMYK

proc asCMY*[T: SomeColor](c: T): ColorCMY =
  when T is Color:
    result = c.RGB_to_CMY
  elif T is ColorCMY:
    result = c
  else:
    result = c.asRGB.RGB_to_CMY

proc asXYZ*[T: SomeColor](c: T): ColorXYZ =
  when T is Color:
    result = c.RGB_to_XYZ
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
  else:
    result = c.asRGB.RGB_to_XYZ

proc asLAB*[T: SomeColor](c: T): ColorLAB =
  when T is ColorXYZ:
    result = c.XYZ_to_LAB
  elif T is ColorLAB:
    result = c
  elif T is ColorPolarLAB:
    result = c.polarLAB_to_LAB
  else:
    result = c.asXYZ.XYZ_to_LAB

proc asPolarLAB*[T: SomeColor](c: T): ColorPolarLAB =
  when T is ColorLab:
    result = c.LAB_to_polarLAB
  elif T is ColorPolarLAB:
    result = c
  else:
    result = c.asLAB.LAB_to_polarLAB

proc asLUV*[T: SomeColor](c: T): ColorLUV =
  when T is ColorXYZ:
    result = c.XYZ_to_LUV
  elif T is ColorLUV:
    result = c
  elif T is ColorPolarLUV:
    result = c.polarLUV_to_LUV
  else:
    result = c.asXYZ.XYZ_to_LUV

proc asPolarLUV*[T: SomeColor](c: T): ColorPolarLUV =
  when T is ColorLab:
    result = c.LUV_to_polarLUV
  elif T is ColorPolarLUV:
    result = c
  else:
    result = c.asLUV.LUV_to_polarLUV
