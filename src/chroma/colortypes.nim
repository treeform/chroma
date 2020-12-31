type
  Color* = object
    ## Main color type, float32 points
    r*: float32 ## red (0-1)
    g*: float32 ## green (0-1)
    b*: float32 ## blue (0-1)
    a*: float32 ## alpha (0-1, 0 is fully transparent)

  # Color Space: rgb
  ColorRGB* = object
    ## Color stored as 3 uint8s
    r*: uint8 ## Red 0-255
    g*: uint8 ## Green 0-255
    b*: uint8 ## Blue 0-255

  # Color Space: rgba
  ColorRGBA* = object
    ## Color stored as 4 uint8s
    r*: uint8 ## Red 0-255
    g*: uint8 ## Green 0-255
    b*: uint8 ## Blue 0-255
    a*: uint8 ## Alpha 0-255

  # Color Space: cmy
  ColorCMY* = object
    ## CMY colors are reverse of rgb and as 100%
    c*: float32 ## Cyan 0 to 100
    m*: float32 ## Magenta 0 to 100
    y*: float32 ## Yellow 0 to 100

  # Color Space: cmyk
  ColorCMYK* = object
    ## CMYK colors are used in printing
    c*: float32 ## Cyan 0 to 1
    m*: float32 ## Magenta 0 to 1
    y*: float32 ## Yellow 0 to 1
    k*: float32 ## Black 0 to 1

  # Color Space: HSL
  ColorHSL* = object
    ## HSL attempts to resemble more perceptual color models
    h*: float32 ## hue 0 to 360
    s*: float32 ## saturation 0 to 100
    l*: float32 ## lightness 0 to 100

  # Color Space: HSV
  ColorHSV* = object
    ## HSV models the way paints of different colors mix together
    h*: float32 ## hue 0 to 360
    s*: float32 ## saturation 0 to 100
    v*: float32 ## value 0 to 100

  ColorYUV* = object
    ## YUV originally a television color format, still used in digital movies
    y*: float32 ## 0 to 1
    u*: float32 ## -0.5 to 0.5
    v*: float32 ## -0.5 to 0.5

  ColorXYZ* = object
    x*: float32 ## range 0.0 to WhiteX
    y*: float32 ## range 0.0 to WhiteY
    z*: float32 ## range 0.0 to WhiteZ

  ColorLAB* = object
    l*: float32 ## lightness, range 0.0 (black) to 100.0 (white)
    a*: float32 ## green (min) to red (max)
    b*: float32 ## blue (min) to yellow (max)

  ## LAB in polar coordinates
  ## Also known as: CIELCh, CIEHLC
  ## not to be confused with ColorPolarLUV == ColorHCL!
  ColorPolarLAB* = object
    l*: float32 ## lightness, range 0.0 (black) to 100.0 (white)
    c*: float32 ## chroma, range 0.0 to max
    h*: float32 ## hue angle, range 0.0 to 360.0
                ## (red: 0, yellow: 90, green: 180, blue: 270)

  ##  ----- CIE-XYZ <-> CIE-LUV -----
  ColorLUV* = object
    l*: float32 ## lightness, range 0.0 to 100.0
    u*: float32 ## red to green
    v*: float32 ## blue to yellow

  ColorPolarLUV* = object
    h*: float32 ## hue angle, range 0.0 to 360.0
    c*: float32 ## chroma
    l*: float32 ## luminance

  # Alias for PolarLUV, as it might be better known as HCL
  ColorHCL* = ColorPolarLUV

  ColorOklab* = object
    L*: float32 ## perceived lightness
    a*: float32 ## greenless/redness
    b*: float32 ## blueless/yellowless
  
  ColorPolarOklab* = object
    L*: float32 ## perceived lightness
    C*: float32 ## chroma
    h*: float32 ## hue

  SomeColor* = Color|ColorRGB|ColorRGBA|ColorHSL|ColorHSV|ColorCMY|ColorCMYK |
               ColorYUV|ColorLAB|ColorPolarLAB|ColorLUV|ColorPolarLUV|ColorXYZ |
               ColorOklab|ColorPolarOklab

  InvalidColor* = object of ValueError

## Less typing constructors:

proc color*(r, g, b: float32, a: float32 = 1.0): Color {.inline.} =
  ## Creates from floats like:
  ## * color(1,0,0) -> red
  ## * color(0,1,0) -> green
  ## * color(0,0,1) -> blue
  ## * color(0,0,0,1) -> opaque  black
  ## * color(0,0,0,0) -> transparent black
  Color(r: r, g: g, b: b, a: a)

proc rgb*(r, g, b: uint8): ColorRGB {.inline.} =
  ## Creates from uint8s like:
  ## * rgba(255,0,0) -> red
  ## * rgba(0,255,0) -> green
  ## * rgba(0,0,255) -> blue
  ColorRGB(r: r, g: g, b: b)

proc rgba*(r, g, b, a: uint8): ColorRGBA {.inline.} =
  ## Creates from uint8s like:
  ## * rgba(255,0,0) -> red
  ## * rgba(0,255,0) -> green
  ## * rgba(0,0,255) -> blue
  ## * rgba(0,0,0,255) -> opaque  black
  ## * rgba(0,0,0,0) -> transparent black
  ColorRGBA(r: r, g: g, b: b, a: a)

proc cmy*(c, m, y: float32): ColorCMY {.inline.} =
  ColorCMY(c: c, m: m, y: y)

proc cmyk*(c, m, y, k: float32): ColorCMYK {.inline.} =
  ColorCMYK(c: c, m: m, y: y, k: k)

proc hsl*(h, s, l: float32): ColorHSL {.inline.} =
  ColorHSL(h: h, s: s, l: l)

proc hsv*(h, s, v: float32): ColorHSV {.inline.} =
  ColorHSV(h: h, s: s, v: v)

proc yuv*(y, u, v: float32): ColorYUV {.inline.} =
  ColorYUV(y: y, u: u, v: v)

proc xyz*(x, y, z: float32): ColorXYZ {.inline.} =
  ColorXYZ(x: x, y: y, z: z)

proc lab*(l, a, b: float32): ColorLAB {.inline.} =
  ColorLAB(l: l, a: a, b: b)

proc polarLAB*(l, c, h: float32): ColorPolarLAB {.inline.} =
  ColorPolarLAB(l: l, c: c, h: h)

proc luv*(l, u, v: float32): ColorLUV {.inline.} =
  ColorLUV(l: l, u: u, v: v)

proc polarLUV*(h, c, l: float32): ColorPolarLUV {.inline.} =
  ColorPolarLUV(h: h, c: c, l: l)

proc oklab*(L, a, b: float32): ColorOklab {.inline.} =
  ColorOklab(L: L, a: a, b: b)

proc polarOklab*(L, C, h: float32): ColorPolarOklab {.inline.} =
  ColorPolarOklab(L: L, C: C, h: h)
