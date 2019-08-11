import chroma
import unittest
import chroma / transformations

import sequtils, macros, strutils

let arr = @[
  color(1, 0, 0),
  color(0, 1, 0),
  color(0, 0, 1),
  color(1, 1, 1),
  color(0, 0, 0),
  color(0.5, 0.5, 0.5),
  color(0.1, 0.2, 0.3),
  color(0.6, 0.5, 0.4),
  color(0.7, 0.8, 0.9),
  color(0.001, 0.001, 0.001),
  color(0.999, 0.999, 0.999),
  color(0.01, 0.0, 0.0),
  color(0.0, 0.01, 0.0),
  color(0.0, 0.0, 0.01),
]

let arrAlpha = @[
  color(0, 0, 0, 0),
  color(0, 0, 0, 0.25),
  color(0, 0, 0, 0.5),
  color(0, 0, 0, 0.75),
  color(0, 0, 0, 1.0),
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

  test "Space transformations using `as*` procs":
    template space(s: untyped): untyped =
      # generate the type name from the `asXXX` identifier or returns
      # it, if it does not contain `as`.
      if "as" in s.strVal:
        var name = s.strVal.replace("as", "")
        if name == "RGB_type":
          name = "RGB"
        elif name == "RGB":
          name = ""
        ident("Color" & name)
      else:
        s

    proc rewriteAsTo(n: NimNode): NimNode =
      case n.kind
      of nnkIdent:
        # return name of colorspace type
        result = space(n)
      of nnkDotExpr:
        # rewrite and wrap dot expression in `to` calls
        let dotexpr = nnkDotExpr.newTree(
          rewriteAsTo(n[0]),
          ident"to"
        )
        let arg2 = rewriteAsTo(n[1])
        result = nnkCall.newTree(dotexpr)
        result.add arg2
      else: discard

    macro genTo(trafo: untyped): untyped =
      let rewrite = rewriteAsTo(trafo)
      result = quote do:
        to(`rewrite`, Color)
      #echo result.repr

    macro genAs(trafo: untyped): untyped =
      result = quote do:
        `trafo`.asRGB
      #echo result.repr

    template backForth(trafo: untyped): untyped =
      ## Tests transformation both via the given `c.asXXX.asYYY...` transformations,
      ## as well as using the `to(color, <type>)` proc to make sure both work.
      ## Finally it also compares the calls of `c.asXXX...` with those of `c.to(..)...`.
      ## Input is a transformation including the color from which to start, with all
      ## transformations written as dot expressions using `asXXX`.
      # using `as`
      doAssert c.almostEqual(genAs(trafo))
      # using `to`
      doAssert c.almostEqual(genTo(trafo))
      # compare `as` with `to`
      doAssert almostEqual(genAs(trafo), genTo(trafo))

    for c in arr:
      # first the trivial back and forth trafos
      backForth(c.asRGB_type)
      backForth(c.asRGBA)
      backForth(c.asHSL)
      backForth(c.asHSV)
      backForth(c.asYUV)
      backForth(c.asCMYK)
      backForth(c.asCMY)
      backForth(c.asXYZ)
      backForth(c.asLAB)
      backForth(c.asPolarLAB)
      backForth(c.asLUV)
      backForth(c.asPolarLUV)
      # then trafos containing multiple (previously broken) trafos
      backForth(c.asCMYK.asXYZ)
      backForth(c.asCMY.asXYZ)
      backForth(c.asHSL.asHSV.asYUV.asCMYK.asCMY.asXYZ.asLAB.asPolarLAB.asLUV.asPolarLUV)
      backForth(c.asHSL.asHSV.asYUV.asCMYK.asCMY.asXYZ.asLAB.asPolarLAB.asLUV.asPolarLUV.asRGB_type.asRGBA)

  test "More space transformations - compared with R colorspace output":
    macro almostEq(c1, c2: typed, ep = 0.01): untyped =
      let dtype = c1.getTypeImpl
      doAssert dtype == c2.getTypeImpl
      var body = newStmtList()
      var tmpId = ident"tmp"
      body.add quote do:
        var `tmpId` = true
      for field in dtype[2]: # RecList
        let fieldName = field[0]
        body.add quote do:
          if abs(`c1`.`fieldName` - `c2`.`fieldName`) > `ep`:
            `tmpId` = false
      result = quote do:
        block:
          `body`
          `tmpId`

    #func almostEq[T: SomeColor](c1, c2: T, ep = 0.01): bool =
    #  ## Returns true if colors are close
    #  for n, val in fieldPairs(c1):
    #    if abs(c1.n - c2.n) > ep: return false
    #  return true

    const colors = [parseHex("023FA5"),
                    parseHex("6371AF"),
                    parseHex("959CC3"),
                    parseHex("BEC1D4"),
                    parseHex("DBDCE0"),
                    parseHex("E0DBDC"),
                    parseHex("D6BCC0"),
                    parseHex("C6909A"),
                    parseHex("AE5A6D"),
                    parseHex("8E063B")]
    # given those colors convert to some other colorspace and compare with output
    let cRgb = colors.mapIt(it.to(Color))
    let expRgb = [color(0.007843137, 0.24705882, 0.6470588),
                  color(0.388235294, 0.44313725, 0.6862745),
                  color(0.584313725, 0.61176471, 0.7647059),
                  color(0.745098039, 0.75686275, 0.8313725),
                  color(0.858823529, 0.86274510, 0.8784314),
                  color(0.878431373, 0.85882353, 0.8627451),
                  color(0.839215686, 0.73725490, 0.7529412),
                  color(0.776470588, 0.56470588, 0.6039216),
                  color(0.682352941, 0.35294118, 0.4274510),
                  color(0.556862745, 0.02352941, 0.2313725)]
    for i in 0 ..< colors.len:
      check cRgb[i].almostEq(expRgb[i])

    let cXyz = colors.mapIt(it.to(ColorXYZ))
    let expXyz = [xyz(8.59108, 6.283171, 36.347084),
                  xyz(18.78561, 17.556945, 42.944822),
                  xyz(34.12995, 34.105738, 56.399873),
                  xyz(52.18543, 53.840026, 69.912376),
                  xyz(68.25775, 71.628143, 80.730460),
                  xyz(68.98728, 71.677877, 77.891637),
                  xyz(55.22770, 54.069481, 57.382059),
                  xyz(39.09464, 34.287270, 35.121978),
                  xyz(23.87290, 17.417248, 16.568451),
                  xyz(12.01096, 6.198577, 4.700508)]
    for i in 0 ..< colors.len:
      check cXyz[i].almostEq(expXyz[i])

suite "functions":
  test "darken":
    assert darken(color(0.7, 0.8, 0.9), 0.2).toHex() == "6598CB"
  test "lighten":
    assert lighten(color(0.1, 0.8, 0.9), 0.2).toHex() == "75E0EF"
  test "saturate":
    assert saturate(parseHex("6598CC"), 0.2).toHex() == "5097E0"
  test "desaturate":
    assert desaturate(parseHex("75E0EF"), 0.2).toHex() == "84D4DF"
  test "spin":
    assert spin(parseHex("75E0EF"), 180).toHex() == "EF8374"
  test "mix":
    assert mix(parseHex("FF0000"), parseHex("FF0000")).toHex() == "FF0000"
    assert mix(parseHex("FFFFFF"), parseHex("000000")).toHex() == "7F7F7F"
    assert mix(parseHex("FF0000"), parseHex("00FF00")).toHex() == "7F7F00"


when false:
  # example in readme:
  import chroma

  let
    a = color(0.7, 0.8, 0.9)
    b = color(0.2, 0.3, 0.4, 0.5)

  echo a.toHex()
  echo parseHex("BADA55")
  echo parseHtmlName("red")
  echo hsv(b).color()
  echo a.darken(0.2)
  echo mix(a, b)
