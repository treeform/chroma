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
    ## YUV origially a television color format, still used in digital movies
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

  SomeColor* = Color|ColorRGB|ColorRGBA|ColorHSL|ColorHSV|ColorCMY|ColorCMYK |
               ColorYUV|ColorLAB|ColorPolarLAB|ColorLUV|ColorPolarLUV|ColorXYZ

  InvalidColor* = object of ValueError
