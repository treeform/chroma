import chroma
import unittest


let arr = @[
  color(1,0,0),
  color(0,1,0),
  color(0,0,1),
  color(1,1,1),
  color(0,0,0),
  color(0.5,0.5,0.5),
  color(0.1,0.2,0.3),
  color(0.6,0.5,0.4),
  color(0.7,0.8,0.9),
  color(0.001,0.001,0.001),
  color(0.999,0.999,0.999),
  color(0.01,0.0,0.0),
  color(0.0,0.01,0.0),
  color(0.0,0.0,0.01),
]

let arrAlpha = @[
  color(0,0,0,0),
  color(0,0,0,0.25),
  color(0,0,0,0.5),
  color(0,0,0,0.75),
  color(0,0,0,1.0),
]


suite "parsers":
  test "hex":
    for c in arr:
      #echo "parseHex/toHex", c, " -> ", toHex(c)
      assert c.almostEqual(parseHex(c.toHex()))

  test "HtmlRgb":
    for c in arr:
      #echo "parseHtmlRgb/toHtmlRgb", c, " -> ", toHtmlRgb(c)
      assert c.almostEqual(parseHtmlRgb(c.toHtmlRgb()))

  test "HtmlRgba":
    for c in arr & arrAlpha:
      #echo "parseHtmlRgba/toHtmlRgba", c, " -> ", toHtmlRgba(c)
      assert c.almostEqual(parseHtmlRgba(c.toHtmlRgba()))

  test "HexAlpha":
    for c in arr & arrAlpha:
      #echo "parseHexAlpha/toHexAlpha", c, " -> ", toHexAlpha(c)
      assert c.almostEqual(parseHexAlpha(c.toHexAlpha()))

  test "HtmlHex":
    for c in arr & arrAlpha:
      #echo "parseHtmlHex/toHtmlHex", c, " -> ", toHtmlHex(c)
      assert c.almostEqual(parseHtmlHex(c.toHtmlHex()))

  test "HtmlHexTiny":
    for c in arr & arrAlpha:
      #echo "parseHtmlHexTiny/toHtmlHexTiny", c, " -> ", toHtmlHexTiny(c)
      assert c.almostEqual(parseHtmlHexTiny(c.toHtmlHexTiny()), 0.1)

  test "HtmlName":
    assert parseHtmlName("red").toHex() == "FF0000"
    assert parseHtmlName("green").toHex() == "008000"
    assert parseHtmlName("blue").toHex() == "0000FF"
    assert parseHtmlName("white").toHex() == "FFFFFF"
    assert parseHtmlName("black").toHex() == "000000"

  test "parseHtmlColor":
    assert parseHtmlColor("#f00").toHex() == "FF0000"
    assert parseHtmlColor("#008000").toHex() == "008000"
    assert parseHtmlColor("rgb(0,0,255)").toHex() == "0000FF"
    assert parseHtmlColor("rgba(255,255,255,255)").toHex() == "FFFFFF"
    assert parseHtmlColor("black").toHex() == "000000"


suite "spaces":
  test "RGB":
    let _ = ColorRGB()
    for c in arr:
      #echo "RGB", c, " -> ", rgb(c)
      assert c.almostEqual(rgb(c).color())

  test "RGBA":
    let _ = ColorRGBA()
    for c in arr & arrAlpha:
      #echo "RGBA", c, " -> ", rgba(c)
      assert c.almostEqual(rgba(c).color())

  test "CMY":
    let _ = ColorCMY()
    for c in arr:
      #echo "CMY", c, " -> ", cmy(c)
      assert c.almostEqual(cmy(c).color())

  test "CMYK":
    let _ = ColorCMYK()
    for c in arr:
      #echo "CMYK", c, " -> ", cmyk(c)
      assert c.almostEqual(cmyk(c).color())

  test "HSL":
    let _ = ColorHSL()
    for c in arr:
      #echo "HSL", c, " -> ", hsl(c)
      assert c.almostEqual(hsl(c).color())

  test "HSV":
    let _ = ColorHSV()
    for c in arr:
      #echo "HSV", c, " -> ", hsv(c)
      assert c.almostEqual(hsv(c).color())

  test "YUV":
    let _ = ColorYUV()
    for c in arr:
      #echo "YUV", c, " -> ", yuv(c)
      assert c.almostEqual(yuv(c).color())


suite "functions":
  test "darken":
    assert darken(color(0.7,0.8,0.9), 0.2).toHex() == "6598CC"
  test "lighten":
    echo lighten(color(0.1,0.8,0.9), 0.2).toHex()
    assert lighten(color(0.1,0.8,0.9), 0.2).toHex() == "75E0EF"

# example in readme:
let
  a = color(0.7,0.8,0.9)
  b = color(0.2,0.3,0.4,0.5)

echo a.toHex()
echo parseHex("BADA55")
echo parseHtmlName("red")
echo hsv(b).color()
echo a.darken(0.2)