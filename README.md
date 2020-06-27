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

These are generated based on the Nim types with the
`generateConvenienceProcs` macro in `chroma.nim`.

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

## **proc** hash

Hahses a color - used in tables.

```nim
proc hash(c: Color): Hash
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

## **proc** to

Allows conversion of transformation of a color in any colorspace into any other colorspace.

```nim
proc to[T: SomeColor](c: SomeColor; toColor: typedesc[T]): T
```

## **proc** color


```nim
proc color(c: ColorRGB): Color
```

## **proc** rgb


```nim
proc rgb(c: Color): ColorRGB
```

## **proc** rgb


```nim
proc rgb(r: uint8; g: uint8; b: uint8): ColorRGB
```

## **proc** color


```nim
proc color(c: ColorRGBA): Color
```

## **proc** rgba


```nim
proc rgba(c: Color): ColorRGBA
```

## **proc** rgba


```nim
proc rgba(r: uint8; g: uint8; b: uint8; a: uint8): ColorRGBA
```

## **proc** color


```nim
proc color(c: ColorHSL): Color
```

## **proc** hsl


```nim
proc hsl(c: Color): ColorHSL
```

## **proc** hsl


```nim
proc hsl(h: float32; s: float32; l: float32): ColorHSL
```

## **proc** color


```nim
proc color(c: ColorHSV): Color
```

## **proc** hsv


```nim
proc hsv(c: Color): ColorHSV
```

## **proc** hsv


```nim
proc hsv(h: float32; s: float32; v: float32): ColorHSV
```

## **proc** color


```nim
proc color(c: ColorCMY): Color
```

## **proc** cmy


```nim
proc cmy(c: Color): ColorCMY
```

## **proc** cmy


```nim
proc cmy(c: float32; m: float32; y: float32): ColorCMY
```

## **proc** color


```nim
proc color(c: ColorCMYK): Color
```

## **proc** cmyk


```nim
proc cmyk(c: Color): ColorCMYK
```

## **proc** cmyk


```nim
proc cmyk(c: float32; m: float32; y: float32; k: float32): ColorCMYK
```

## **proc** color


```nim
proc color(c: ColorYUV): Color
```

## **proc** yuv


```nim
proc yuv(c: Color): ColorYUV
```

## **proc** yuv


```nim
proc yuv(y: float32; u: float32; v: float32): ColorYUV
```

## **proc** color


```nim
proc color(c: ColorLAB): Color
```

## **proc** lab


```nim
proc lab(c: Color): ColorLAB
```

## **proc** lab


```nim
proc lab(l: float32; a: float32; b: float32): ColorLAB
```

## **proc** color


```nim
proc color(c: ColorPolarLAB): Color
```

## **proc** polarlab


```nim
proc polarlab(c: Color): ColorPolarLAB
```

## **proc** polarlab


```nim
proc polarlab(l: float32; c: float32; h: float32): ColorPolarLAB
```

## **proc** color


```nim
proc color(c: ColorLUV): Color
```

## **proc** luv


```nim
proc luv(c: Color): ColorLUV
```

## **proc** luv


```nim
proc luv(l: float32; u: float32; v: float32): ColorLUV
```

## **proc** color


```nim
proc color(c: ColorPolarLUV): Color
```

## **proc** polarluv


```nim
proc polarluv(c: Color): ColorPolarLUV
```

## **proc** polarluv


```nim
proc polarluv(h: float32; c: float32; l: float32): ColorPolarLUV
```

## **proc** color


```nim
proc color(c: ColorXYZ): Color
```

## **proc** xyz


```nim
proc xyz(c: Color): ColorXYZ
```

## **proc** xyz


```nim
proc xyz(x: float32; y: float32; z: float32): ColorXYZ
```

## **proc** hcl


```nim
proc hcl(c: Color): ColorHCL
```

## **proc** hcl


```nim
proc hcl(h, c, l: float32): ColorHCL
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

Mixes two Color colors together using simple avarage.

```nim
proc mix(a, b: Color): Color
```

## **proc** mixCMYK

Mixes two colors together using CMYK.

```nim
proc mixCMYK(colorA, colorB: Color): Color
```

## **proc** mix

Mixes two ColorRGBA colors together using simple avarage.

```nim
proc mix(a, b: ColorRGBA): ColorRGBA
```

## **func** distance

A distance function based on CIEDE2000 color difference formula

```nim
func distance(c1, c2: SomeColor): float32
```
