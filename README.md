# Chroma - Everything you want to do with colors.

Docs: https://treeform.github.io/chroma/

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
* YUV origially a television color format, still used in digital movies

## Color Functions

You can use these to change colors you already have
* `lighten(color, amout)` Lightens the color by amount 0-1
* `darken(color, amout)` Darkens the color by amount 0-1
* `saturate(color, amout)` Saturates (makes brighter) the color by amount 0-1
* `desaturate(color, amout)` Desaturate (makes grayer) the color by amount 0-1
* `spin(color, degrees)` Rotates the hue of the color by degrees (0-360)
* `mix(colorA, colorB)` Mixes two colors together using CMYK

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
