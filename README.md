# Chroma - Everything you want to do with colors.

## Parse/Format

Common color parsers and formatters:
* `hex` - `FFFFFF`
* `HtmlHexTiny` - `#FFF`
* `HtmlHex` - `#FFFFFF`
* `HtmlRgb` - `rgb(255, 255, 255)`
* `HtmlRgba` - `rgba(255, 255, 255, 1.0)`
* `HtmlName` - `white`
* `HexAlpha` - `FFFFFFFF`
* `parseHtmlColor` - Any of the HTML formats.

## Color Spaces

Conversion from and to these colors spaces:
* 8-bit RGB
* 8-bit RGBA
* CMY colors are reverse of rgb
* CMYK colors are used in printing
* HSL attempts to resemble more perceptual color models
* HSV models the way paints of different colors mix together
* YUV origially a television color format, still used in digital
  movies
* XYZ (CIE `XYZ`; CIE 1931 color space)
* LAB (CIE `L*a*b*`, CIELAB), derived from XYZ (Note: a fixed white
  point is assumed)
* CIELCh, LAB in polar coordinates (type: `ColorPolarLAB`)
* LUV (CIE `L*u*v*`, CIELUV), derived from XYZ (Note: a fixed white
  point is assumed)
* CIELCH, LUV in polar coordinates (type: `ColorPolarLUV`), often
  called HCL

The default type is an RGB based type using `float32` as its base type
(with values ranging from 0 to 1) and is called `Color`. All the above
color spaces have corresponding type names of `Color<ColorSpaceName>`,
where `ColorSpaceName` is the name in the bullet points above (unless
specified by "type:" in parenthesis).

Convenience procs to convert from and to the default type `Color` are
provided in the form of
* `proc color(c: Color<ColorSpaceName>): Color`

and the inverse:
* `proc <colorSpaceName>(c: Color): Color<ColorSpaceName>`.

and using the field names:
* `proc <colorSpaceName>(<fieldName1>, <fieldName2>, <fieldName3>: <fieldType>): Color<ColorSpaceName>`

## Color Functions

You can use these to change colors you already have
* `lighten(color, amout)` Lightens the color by amount 0-1
* `darken(color, amout)` Darkens the color by amount 0-1
* `saturate(color, amout)` Saturates (makes brighter) the color by amount 0-1
* `desaturate(color, amout)` Desaturate (makes grayer) the color by amount 0-1
* `spin(color, degrees)` Rotates the hue of the color by degrees (0-360)
* `mix(colorA, colorB)` Mixes two colors together using CMYK

A distance function is provided that implements
[CIEDE2000 color difference formula](https://en.wikipedia.org/wiki/Color_difference#CIEDE2000)
* `distance(colorA, colorB)` Distance between two colors

This distance is designed to be perceptually uniform and it can be used to answer the question:
"What is a set of colors that are imperceptibly/acceptably close to a given reference?".
A value of 5.0 is used as reference in [github linguist library](https://github.com/github/linguist/):
any color with distance less than 5.0 from one of the existing colors is not allowed.

## Example

```nim
import chroma

let
    a = color(0.7,0.8,0.9)
    b = color(0.2,0.3,0.4,0.5)

echo a.toHex()
echo parseHex("BADA55")
echo parseHtmlName("red")
echo hsv(b).color()
echo a.darken(0.2)
echo mix(a, b)
```

# API: chroma

```nim
import chroma
```

## **proc** `$`

Returns colors as "(r, g, b, a)".

```nim
proc `$`(c: Color): string
```

## **func** hash

Hashes a Color - used in tables.

```nim
func hash(c: Color): Hash
```

## **func** hash

Hashes a ColorRGB - used in tables.

```nim
func hash(c: ColorRGB): Hash
```

## **func** hash

Hashes a ColorRGB - used in tables.

```nim
func hash(c: ColorRGBA): Hash
```

## **func** hash

Hashes a ColorCMY - used in tables.

```nim
func hash(c: ColorCMY): Hash
```

## **func** hash

Hashes a ColorCMYK - used in tables.

```nim
func hash(c: ColorCMYK): Hash
```

## **func** hash

Hashes a ColorHSL - used in tables.

```nim
func hash(c: ColorHSL): Hash
```

## **func** hash

Hashes a ColorHSV - used in tables.

```nim
func hash(c: ColorHSV): Hash
```

## **func** hash

Hashes a ColorYUV - used in tables.

```nim
func hash(c: ColorYUV): Hash
```

## **func** hash

Hashes a ColorXYZ - used in tables.

```nim
func hash(c: ColorXYZ): Hash
```

## **func** hash

Hashes a ColorLAB - used in tables.

```nim
func hash(c: ColorLAB): Hash
```

## **func** hash

Hashes a ColorPolarLAB - used in tables.

```nim
func hash(c: ColorPolarLAB): Hash
```

## **func** hash

Hashes a ColorLUV - used in tables.

```nim
func hash(c: ColorLUV): Hash
```

## **func** hash

Hashes a ColorPolarLUV - used in tables.

```nim
func hash(c: ColorPolarLUV): Hash
```

## **proc** almostEqual

Returns true if colors are close

```nim
proc almostEqual(a, b: Color; ep = 0.01): bool
```

## **proc** parseHex

Parses colors like:
 * FF0000 -> red
 * 0000FF -> blue
 * FFFFFF -> white

```nim
proc parseHex(hex: string): Color {.raises: [InvalidColor].}
```

## **proc** toHex

Formats color as hex (upper case):
 * red -> FF0000
 * blue -> 0000FF
 * white -> FFFFFF

```nim
proc toHex(c: Color): string
```

## **proc** parseHexAlpha

Parses colors like:
 * FF0000FF -> red
 * 0000FFFF -> blue
 * FFFFFFFF -> white
 * 000000FF -> opaque  black
 * 00000000 -> transparent black

```nim
proc parseHexAlpha(hex: string): Color {.raises: [InvalidColor].}
```

## **proc** toHexAlpha

Formats color as hex (upper case):
 * red -> FF0000FF
 * blue -> 0000FFFF
 * white -> FFFFFFFF
 * opaque  black -> 000000FF
 * transparent black -> 00000000

```nim
proc toHexAlpha(c: Color): string
```

## **proc** parseHtmlHex

Parses colors with leading '#' like::
 * #FF0000 -> red
 * #0000ff -> blue
 * #ffffff -> white

```nim
proc parseHtmlHex(hex: string): Color {.raises: [InvalidColor].}
```

## **proc** toHtmlHex

Formats color as HTML hex (upper case):
 * red -> #FF0000
 * blue -> #0000FF
 * white -> #FFFFFF

```nim
proc toHtmlHex(c: Color): string
```

## **proc** parseHtmlHexTiny

Parses colors with leading '#' and 3 hex numbers like::
 * #F00 -> red
 * #0ff -> blue
 * #fff -> white

```nim
proc parseHtmlHexTiny(hex: string): Color {.raises: [InvalidColor].}
```

## **proc** toHtmlHexTiny

Formats color as HTML 3 hex numbers (upper case):
 * red -> #F00
 * blue -> #00F
 * white -> #FFF

```nim
proc toHtmlHexTiny(c: Color): string
```

## **proc** parseHtmlRgb

Parses colors in html's rgb format:
 * rgb(255, 0, 0) -> red
 * rgb(0,0,255) -> blue
 * rgb(255,255,255) -> white

```nim
proc parseHtmlRgb(text: string): Color {.raises: [InvalidColor, ValueError].}
```

## **proc** toHtmlRgb

Parses colors in html's rgb format:
 * red -> rgb(255, 0, 0)
 * blue -> rgb(0,0,255)
 * white -> rgb(255,255,255)

```nim
proc toHtmlRgb(c: Color): string
```

## **proc** parseHtmlRgba

Parses colors in html's rgba format:
 * rgba(255, 0, 0, 1.0) -> red
 * rgba(0,0,255, 1.0) -> blue
 * rgba(255,255,255, 1.0) -> white
 * rgba(0,0,0,1.0) -> opaque  black
 * rgba(0,0,0,0.0) -> transparent black

<p>Note: rgb is 0-255, while alpha is 0 to 1.</p>

```nim
proc parseHtmlRgba(text: string): Color {.raises: [InvalidColor, ValueError].}
```

## **proc** toHtmlRgba

Parses colors in html's rgb format:
 * red -> rgb(255, 0, 0)
 * blue -> rgb(0,0,255)
 * white -> rgb(255,255,255)

```nim
proc toHtmlRgba(c: Color): string
```

## **proc** parseHtmlName

Parses HTML color as as a name:
 * "red"
 * "blue"
 * "white"
 * "amber"
 * "Lavender Gray"

```nim
proc parseHtmlName(text: string): Color {.raises: [InvalidColor, KeyError].}
```

## **proc** parseHtmlColor

Parses HTML color any any of the formats:
 * #FFF
 * #FFFFFF
 * rgb(255, 255, 255)
 * rgba(255, 255, 255, 1.0)
 * white

```nim
proc parseHtmlColor(colorText: string): Color {.raises: [InvalidColor, ValueError, KeyError].}
```

## **proc** lighten

Lightens the color by amount 0-1.

```nim
proc lighten(color: Color; amount: float32): Color
```

## **proc** darken

Darkens the color by amount 0-1.

```nim
proc darken(color: Color; amount: float32): Color
```

## **proc** saturate

Saturates (makes brighter) the color by amount 0-1.

```nim
proc saturate(color: Color; amount: float32): Color
```

## **proc** desaturate

Desaturate (makes grayer) the color by amount 0-1.

```nim
proc desaturate(color: Color; amount: float32): Color
```

## **proc** spin

Rotates the hue of the color by degrees (0-360).

```nim
proc spin(color: Color; degrees: float32): Color
```

## **proc** mix

Mixes two Color colors together using simple average.

```nim
proc mix(a, b: Color): Color
```

## **proc** mix

Mixes two Color colors together using simple lerp.

```nim
proc mix(a, b: Color; v: float32): Color
```

## **proc** mixCMYK

Mixes two colors together using CMYK.

```nim
proc mixCMYK(colorA, colorB: Color): Color
```

## **proc** mix

Mixes two ColorRGB colors together using simple average.

```nim
proc mix(a, b: ColorRGB): ColorRGB
```

## **proc** mix

Mixes two ColorRGBA colors together using simple average.

```nim
proc mix(a, b: ColorRGBA): ColorRGBA
```

## **func** distance

A distance function based on CIEDE2000 color difference formula

```nim
func distance(c1, c2: SomeColor): float32
```

## **type** Color

Main color type, float32 points

```nim
Color = object
 r*: float32 ## red (0-1)
 g*: float32 ## green (0-1)
 b*: float32 ## blue (0-1)
 a*: float32 ## alpha (0-1, 0 is fully transparent)
```

## **type** ColorRGB

Color stored as 3 uint8s

```nim
ColorRGB = object
 r*: uint8 ## Red 0-255
 g*: uint8 ## Green 0-255
 b*: uint8 ## Blue 0-255
```

## **type** ColorRGBA

Color stored as 4 uint8s

```nim
ColorRGBA = object
 r*: uint8 ## Red 0-255
 g*: uint8 ## Green 0-255
 b*: uint8 ## Blue 0-255
 a*: uint8 ## Alpha 0-255
```

## **type** ColorCMY

CMY colors are reverse of rgb and as 100%

```nim
ColorCMY = object
 c*: float32 ## Cyan 0 to 100
 m*: float32 ## Magenta 0 to 100
 y*: float32 ## Yellow 0 to 100
```

## **type** ColorCMYK

CMYK colors are used in printing

```nim
ColorCMYK = object
 c*: float32 ## Cyan 0 to 1
 m*: float32 ## Magenta 0 to 1
 y*: float32 ## Yellow 0 to 1
 k*: float32 ## Black 0 to 1
```

## **type** ColorHSL

HSL attempts to resemble more perceptual color models

```nim
ColorHSL = object
 h*: float32 ## hue 0 to 360
 s*: float32 ## saturation 0 to 100
 l*: float32 ## lightness 0 to 100
```

## **type** ColorHSV

HSV models the way paints of different colors mix together

```nim
ColorHSV = object
 h*: float32 ## hue 0 to 360
 s*: float32 ## saturation 0 to 100
 v*: float32 ## value 0 to 100
```

## **type** ColorYUV

YUV originally a television color format, still used in digital movies

```nim
ColorYUV = object
 y*: float32 ## 0 to 1
 u*: float32 ## -0.5 to 0.5
 v*: float32 ## -0.5 to 0.5
```

## **type** ColorXYZ


```nim
ColorXYZ = object
 x*: float32 ## range 0.0 to WhiteX
 y*: float32 ## range 0.0 to WhiteY
 z*: float32 ## range 0.0 to WhiteZ
```

## **type** ColorLAB


```nim
ColorLAB = object
 l*: float32 ## lightness, range 0.0 (black) to 100.0 (white)
 a*: float32 ## green (min) to red (max)
 b*: float32 ## blue (min) to yellow (max)
```

## **type** ColorPolarLAB


```nim
ColorPolarLAB = object
 l*: float32 ## lightness, range 0.0 (black) to 100.0 (white)
 c*: float32 ## chroma, range 0.0 to max
 h*: float32 ## hue angle, range 0.0 to 360.0
 ## (red: 0, yellow: 90, green: 180, blue: 270)
```

## **type** ColorLUV


```nim
ColorLUV = object
 l*: float32 ## lightness, range 0.0 to 100.0
 u*: float32 ## red to green
 v*: float32 ## blue to yellow
```

## **type** ColorPolarLUV


```nim
ColorPolarLUV = object
 h*: float32 ## hue angle, range 0.0 to 360.0
 c*: float32 ## chroma
 l*: float32 ## luminance
```

## **type** ColorHCL


```nim
ColorHCL = ColorPolarLUV
```

## **type** SomeColor


```nim
SomeColor = Color | ColorRGB | ColorRGBA | ColorHSL | ColorHSV | ColorCMY |
 ColorCMYK |
 ColorYUV |
 ColorLAB |
 ColorPolarLAB |
 ColorLUV |
 ColorPolarLUV |
 ColorXYZ
```

## **type** InvalidColor


```nim
InvalidColor = object of ValueError
```

## **proc** color

Creates from floats like:
 * color(1,0,0) -> red
 * color(0,1,0) -> green
 * color(0,0,1) -> blue
 * color(0,0,0,1) -> opaque  black
 * color(0,0,0,0) -> transparent black

```nim
proc color(r, g, b: float32; a: float32 = 1.0): Color {.inline.}
```

## **proc** rgb

Creates from uint8s like:
 * rgba(255,0,0) -> red
 * rgba(0,255,0) -> green
 * rgba(0,0,255) -> blue

```nim
proc rgb(r, g, b: uint8): ColorRGB {.inline.}
```

## **proc** rgba

Creates from uint8s like:
 * rgba(255,0,0) -> red
 * rgba(0,255,0) -> green
 * rgba(0,0,255) -> blue
 * rgba(0,0,0,255) -> opaque  black
 * rgba(0,0,0,0) -> transparent black

```nim
proc rgba(r, g, b, a: uint8): ColorRGBA {.inline.}
```

## **proc** cmy


```nim
proc cmy(c, m, y: float32): ColorCMY {.inline.}
```

## **proc** cmyk


```nim
proc cmyk(c, m, y, k: float32): ColorCMYK {.inline.}
```

## **proc** hsl


```nim
proc hsl(h, s, l: float32): ColorHSL {.inline.}
```

## **proc** hsv


```nim
proc hsv(h, s, v: float32): ColorHSV {.inline.}
```

## **proc** yuv


```nim
proc yuv(y, u, v: float32): ColorYUV {.inline.}
```

## **proc** xyz


```nim
proc xyz(x, y, z: float32): ColorXYZ {.inline.}
```

## **proc** lab


```nim
proc lab(l, a, b: float32): ColorLAB {.inline.}
```

## **proc** polarLAB


```nim
proc polarLAB(l, c, h: float32): ColorPolarLAB {.inline.}
```

## **proc** luv


```nim
proc luv(l, u, v: float32): ColorLUV {.inline.}
```

## **proc** polarLUV


```nim
proc polarLUV(h, c, l: float32): ColorPolarLUV {.inline.}
```

## **func** deltaE00


```nim
func deltaE00(c1, c2: ColorLAB; kL, kC, kH = 1.float32): float32
```

## **proc** rgb

Convert Color to ColorRGB

```nim
proc rgb(c: Color): ColorRGB {.inline.}
```

## **proc** color

Convert ColorRGB to Color

```nim
proc color(c: ColorRGB): Color {.inline.}
```

## **proc** rgba

Convert Color to ColorRGBA

```nim
proc rgba(c: Color): ColorRGBA {.inline.}
```

## **proc** color

Convert ColorRGBA to Color

```nim
proc color(c: ColorRGBA): Color {.inline.}
```

## **proc** hsl

convert Color to ColorHSL

```nim
proc hsl(c: Color): ColorHSL
```

## **proc** color

convert ColorHSL to Color

```nim
proc color(c: ColorHSL): Color
```

## **proc** hsv

convert Color to ColorHSV

```nim
proc hsv(c: Color): ColorHSV
```

## **proc** color

convert ColorHSV to Color

```nim
proc color(c: ColorHSV): Color
```

## **proc** yuv

convert Color to ColorYUV

```nim
proc yuv(c: Color): ColorYUV {.inline.}
```

## **proc** color

convert ColorYUV to Color

```nim
proc color(c: ColorYUV): Color {.inline.}
```

## **proc** cmy

convert Color to ColorCMY

```nim
proc cmy(c: Color): ColorCMY {.inline.}
```

## **proc** color

convert ColorCMY to Color

```nim
proc color(c: ColorCMY): Color {.inline.}
```

## **proc** cmyk

convert Color to ColorCMYK

```nim
proc cmyk(c: Color): ColorCMYK {.inline.}
```

## **proc** color

convert ColorCMYK to Color

```nim
proc color(color: ColorCMYK): Color {.inline.}
```

## **func** xyz


```nim
func xyz(c: Color): ColorXYZ {.inline.}
```

## **proc** color


```nim
proc color(c: ColorXYZ): Color {.inline.}
```

## **const** kappa


```nim
kappa: float32 = 903.2962962962963
```

## **const** epsilon


```nim
epsilon: float32 = 0.008856451679035631
```

## **proc** xyz


```nim
proc xyz(c: ColorLAB): ColorXYZ
```

## **proc** f


```nim
proc f(t: float): float {.inline.}
```

## **proc** lab


```nim
proc lab(c: ColorXYZ): ColorLAB
```

## **proc** polarLAB


```nim
proc polarLAB(c: ColorLAB): ColorPolarLAB
```

## **proc** lab


```nim
proc lab(c: ColorPolarLAB): ColorLAB {.inline.}
```

## **proc** uv


```nim
proc uv(c: ColorXYZ): tuple[u, v: float32]
```

## **proc** luv


```nim
proc luv(c: ColorXYZ): ColorLUV
```

## **proc** xyz


```nim
proc xyz(c: ColorLUV): ColorXYZ
```

## **proc** polarLUV


```nim
proc polarLUV(c: ColorLUV): ColorPolarLUV
```

## **proc** luv


```nim
proc luv(c: ColorPolarLUV): ColorLUV {.inline.}
```

## **proc** lab


```nim
proc lab(c: Color): ColorLAB {.inline.}
```

## **proc** color


```nim
proc color(c: ColorLAB): Color {.inline.}
```

## **proc** polarLAB


```nim
proc polarLAB(c: Color): ColorPolarLAB {.inline.}
```

## **proc** color


```nim
proc color(c: ColorPolarLAB): Color {.inline.}
```

## **proc** luv


```nim
proc luv(c: Color): ColorLUV {.inline.}
```

## **proc** color


```nim
proc color(c: ColorLUV): Color {.inline.}
```

## **proc** polarLUV


```nim
proc polarLUV(c: Color): ColorPolarLUV {.inline.}
```

## **proc** color


```nim
proc color(c: ColorPolarLUV): Color {.inline.}
```

## **proc** color


```nim
proc color(c: Color): Color {.inline.}
```

## **proc** to

Allows conversion of transformation of a color in any color space into any other color space.

```nim
proc to[T: SomeColor](c: SomeColor; toColor: typedesc[T]): T {.inline.}
```

## **proc** asColor


```nim
proc asColor(c: SomeColor): Color {.inline.}
```

## **proc** asRgb


```nim
proc asRgb(c: SomeColor): ColorRGB {.inline.}
```

## **proc** asRgba


```nim
proc asRgba(c: SomeColor): ColorRGBA {.inline.}
```

## **proc** asCmy


```nim
proc asCmy(c: SomeColor): ColorCMY {.inline.}
```

## **proc** asCmyk


```nim
proc asCmyk(c: SomeColor): ColorCMYK {.inline.}
```

## **proc** asHsl


```nim
proc asHsl(c: SomeColor): ColorHSL {.inline.}
```

## **proc** asHsv


```nim
proc asHsv(c: SomeColor): ColorHSV {.inline.}
```

## **proc** asYuv


```nim
proc asYuv(c: SomeColor): ColorYUV {.inline.}
```

## **proc** asXyz


```nim
proc asXyz(c: SomeColor): ColorXYZ {.inline.}
```

## **proc** asLab


```nim
proc asLab(c: SomeColor): ColorLAB {.inline.}
```

## **proc** asPolarLAB


```nim
proc asPolarLAB(c: SomeColor): ColorPolarLAB {.inline.}
```

## **proc** asLuv


```nim
proc asLuv(c: SomeColor): ColorLUV {.inline.}
```

## **proc** asPolarLuv


```nim
proc asPolarLuv(c: SomeColor): ColorPolarLUV {.inline.}
```
