import chroma, chroma/transformations, std/macros, std/sequtils, std/strutils, std/unittest, std/math

when not defined(js):
  import parsecsv

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

  test "More space transformations - compared with R colorspace output":
    macro almostEq(c1, c2: typed, ep = 0.01): untyped =
      ## generates a `almostEqual` proc for any given color space object type,
      ## by iterating over all fields if the types are equal and comparing each
      ## field's difference with `ep`
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

    const colors = [
      parseHex("023FA5"),
      parseHex("6371AF"),
      parseHex("959CC3"),
      parseHex("BEC1D4"),
      parseHex("DBDCE0"),
      parseHex("E0DBDC"),
      parseHex("D6BCC0"),
      parseHex("C6909A"),
      parseHex("AE5A6D"),
      parseHex("8E063B")
    ]
    # given those colors convert to some other colorspace and compare with output
    let cRgb = colors.mapIt(it.to(Color))
    let expRgb = [
      color(0.007843137, 0.24705882, 0.6470588),
      color(0.388235294, 0.44313725, 0.6862745),
      color(0.584313725, 0.61176471, 0.7647059),
      color(0.745098039, 0.75686275, 0.8313725),
      color(0.858823529, 0.86274510, 0.8784314),
      color(0.878431373, 0.85882353, 0.8627451),
      color(0.839215686, 0.73725490, 0.7529412),
      color(0.776470588, 0.56470588, 0.6039216),
      color(0.682352941, 0.35294118, 0.4274510),
      color(0.556862745, 0.02352941, 0.2313725)
    ]
    for i in 0 ..< colors.len:
      check cRgb[i].almostEq(expRgb[i])

    let cXyz = colors.mapIt(it.to(ColorXYZ))
    let expXyz = [
      xyz(8.59108, 6.283171, 36.347084),
      xyz(18.78561, 17.556945, 42.944822),
      xyz(34.12995, 34.105738, 56.399873),
      xyz(52.18543, 53.840026, 69.912376),
      xyz(68.25775, 71.628143, 80.730460),
      xyz(68.98728, 71.677877, 77.891637),
      xyz(55.22770, 54.069481, 57.382059),
      xyz(39.09464, 34.287270, 35.121978),
      xyz(23.87290, 17.417248, 16.568451),
      xyz(12.01096, 6.198577, 4.700508)
    ]
    for i in 0 ..< colors.len:
      check cXyz[i].almostEq(expXyz[i])

    let cLab = colors.mapIt(it.to(ColorLAB))
    let expLab = [
      lab(30.11593, 25.6159718, -59.2291843),
      lab(48.95426, 11.2745425, -34.6817925),
      lab(65.04641, 6.0497111, -20.8859330),
      lab(78.36836, 2.6641248, -9.8378624),
      lab(87.78929, 0.3881187, -2.0712282),
      lab(87.81331, 1.8741418, 0.1173351),
      lab(78.50223, 9.8934416, 1.3867208),
      lab(65.18995, 21.8891638, 2.8198948),
      lab(48.78153, 36.2399176, 4.9170323),
      lab(29.90803, 53.0297042, 8.9914552)
    ]
    for i in 0 ..< colors.len:
      check cLab[i].almostEq(expLab[i])

    let cPolarLab = colors.mapIt(it.to(ColorPolarLab))
    let expPolarLab = [
      polarLab(30.11593, 64.531188, 293.387952),
      polarLab(48.95426, 36.468370, 288.008584),
      polarLab(65.04641, 21.744452, 286.153914),
      polarLab(78.36836, 10.192208, 285.152461),
      polarLab(87.78929, 2.107278, 280.613332),
      polarLab(87.81331, 1.877811, 3.582462),
      polarLab(78.50223, 9.990154, 7.978919),
      polarLab(65.18995, 22.070054, 7.340759),
      polarLab(48.78153, 36.571968, 7.726709),
      polarLab(29.90803, 53.786576, 9.623267)
    ]
    for i in 0 ..< colors.len:
      check cPolarLab[i].almostEq(expPolarLab[i])

    let cOklab = colors.mapIt(it.to(ColorOklab))
    let expOklab = [
      oklab(0.6059127, -0.0618687, -0.132093335),
      oklab(0.7673618,  0.0031948, -0.056107075),
      oklab(0.8522680,  0.0036528, -0.029817891),
      oklab(0.9129040,  0.0019834, -0.012930225),
      oklab(0.9521403,  0.0002312, -0.002724297),
      oklab(0.9524956,  0.0026390,  3.44801e-05),
      oklab(0.9144257,  0.0145511,  0.001537969),
      oklab(0.8536680,  0.0347748,  0.002470664),
      oklab(0.7624759,  0.0678392,  0.001605107),
      oklab(0.5607032,  0.2017071, -0.033859189)
    ]
    for i in 0 ..< colors.len:
      check cOklab[i].almostEq(expOklab[i])

    let cPolarOklab = colors.mapIt(it.to(ColorPolarOklab))
    let expPolarOklab = [
      polarOklab(0.60591274, 0.14580541, 244.8921356),
      polarOklab(0.76736181, 0.05619394, 273.2592468),
      polarOklab(0.85226809, 0.03002440, 276.9880981),
      polarOklab(0.91290402, 0.01315032, 278.6747741),
      polarOklab(0.95214039, 0.00271021, 274.8944396),
      polarOklab(0.95249563, 0.00263925,   0.7479323),
      polarOklab(0.91442573, 0.01463048,   5.9677457),
      polarOklab(0.85366809, 0.03486439,   4.1069898),
      polarOklab(0.76247590, 0.06785918,   1.3892900),
      polarOklab(0.56070321, 0.20453040, 350.4690856)
    ]
    for i in 0 ..< colors.len:
      check cPolarOklab[i].almostEq(expPolarOklab[i])

    let cLuv = colors.mapIt(it.to(ColorLUV))
    let expLuv = [
      luv(30.11593, -13.9580496, -78.86780920),
      luv(48.95426, -9.5461094, -53.36486065),
      luv(65.04641, -5.8182031, -32.96385756),
      luv(78.36836, -2.7172101, -15.56125899),
      luv(87.78929, -0.7842912, -3.24049702),
      luv(87.81331, 2.7833622, -0.15499877),
      luv(78.50223, 15.2042643, 0.29225224),
      luv(65.18995, 33.5088794, 0.07679983),
      luv(48.78153, 55.3929249, -0.11567890),
      luv(29.90803, 79.9308245, 0.04076898)
    ]
    for i in 0 ..< colors.len:
      check cLuv[i].almostEq(expLuv[i])

    let cPolarLuv = colors.mapIt(it.to(ColorPolarLuv))
    let expPolarLuv = [
      polarLuv(259.9636996, 80.093436, 30.11593),
      polarLuv(259.8579844, 54.211960, 48.95426),
      polarLuv(259.9902473, 33.473383, 65.04641),
      polarLuv(260.0952278, 15.796709, 78.36836),
      polarLuv(256.3944472, 3.3340570, 87.78929),
      polarLuv(356.8126275, 2.7876750, 87.81331),
      polarLuv(1.101188300, 15.207073, 78.50223),
      polarLuv(0.131317400, 33.508967, 65.18995),
      polarLuv(359.8803475, 55.393046, 48.78153),
      polarLuv(0.029223900, 79.930835, 29.90803)
    ]
    for i in 0 ..< colors.len:
      check cPolarLuv[i].almostEq(expPolarLuv[i])

    let cHsl = colors.mapIt(it.to(ColorHsl))
    let expHsl = [
      hsl(217.5460, 97.604790, 32.74510),
      hsl(228.9474, 32.203390, 53.72549),
      hsl(230.8696, 27.710843, 67.45098),
      hsl(231.8182, 20.370370, 78.82353),
      hsl(228.0000, 07.462687, 86.86275),
      hsl(348.0000, 07.462687, 86.86275),
      hsl(350.7692, 24.074074, 78.82353),
      hsl(348.8889, 32.142857, 67.05882),
      hsl(346.4286, 34.146341, 51.76471),
      hsl(336.6176, 91.891892, 29.01961)
    ]
    for i in 0 ..< colors.len:
      check cHsl[i].almostEq(expHsl[i])

    let cHsv = colors.mapIt(it.to(ColorHsv))
    let expHsv = [
      hsv(217.5460, 98.787879, 64.70588),
      hsv(228.9474, 43.428571, 68.62745),
      hsv(230.8696, 23.589744, 76.47059),
      hsv(231.8182, 10.377358, 83.13725),
      hsv(228.0000, 02.232143, 87.84314),
      hsv(348.0000, 02.232143, 87.84314),
      hsv(350.7692, 12.149533, 83.92157),
      hsv(348.8889, 27.272727, 77.64706),
      hsv(346.4286, 48.275862, 68.23529),
      hsv(336.6176, 95.774648, 55.68627)
    ]
    for i in 0 ..< colors.len:
      check cHsv[i].almostEq(expHsv[i])

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

    #assert lerp(1, 0, 0.0677) == 0.9322999715805054
    assert mix(
      ColorRGB(r: 255, g: 168, b: 85).color,
      ColorRGB(r: 255, g: 63, b: 63).color,
      0.06756756454706192
    ) == color(1.0, 0.6310015916824341, 0.3275039792060852, 1.0)

suite "distance":
  template checkAlmostEqual(x, y: float32, epsilon = 0.0001): untyped =
    check abs(x - y) < epsilon
  test "test vectors":
    when not defined(js):
      # test vectors taken from: http://www2.ece.rochester.edu/~gsharma/ciede2000/
      var x: CsvParser
      x.open("tests/distance_test_vectors.csv")
      x.readHeaderRow()
      assert x.headers == @["c1l", "c1a", "c1b", "c2l", "c2a", "c2b", "deltaE00"]
      var c1, c2: ColorLAB
      var expectedResult, result: float32
      while readRow(x):
        c1 = lab(x.rowEntry("c1l").parseFloat.float32, x.rowEntry(
            "c1a").parseFloat.float32, x.rowEntry("c1b").parseFloat.float32)
        c2 = lab(x.rowEntry("c2l").parseFloat.float32, x.rowEntry(
            "c2a").parseFloat.float32, x.rowEntry("c2b").parseFloat.float32)
        expectedResult = x.rowEntry("deltaE00").parseFloat.float32
        result = distance(c1, c2)
        checkAlmostEqual(expectedResult, result)
  test "example usage from color-proximity":
    # color-proximity (ruby gem): https://github.com/gjtorikian/color-proximity
    # depends on color_difference: https://github.com/mmozuras/color_difference/
    # note that color_difference does scale between 0 and 1 (clipping to 100 all values > 100)
    let
      c0 = "000003".parseHex
      c1 = "000001".parseHex
      c2 = "000002".parseHex
      c3 = "ffffff".parseHex
      res1 = distance(c0, c1) / 100.0
      res2 = distance(c0, c2) / 100.0
      res3 = distance(c0, c3) / 100.0
      expRes1 = 0.00832.float32
      expRes2 = 0.00412.float32
      expRes3 = 0.99948.float32
    checkAlmostEqual(res1, expRes1)
    checkAlmostEqual(res2, expRes2)
    checkAlmostEqual(res3, expRes3)
  test "example of proximity failure":
    # color proximity test in linguist: https://github.com/github/linguist/blob/master/test/test_color_proximity.rb
    let
      c1 = "FFDF00".parseHex # a color proposal for Nim in linguist
      c2 = "FFEC25".parseHex # Dafny color
      result = distance(c1, c2) / 100
    check result < 0.05 # proximity threshold set in linguist

suite "temperature":
  test "compute":
    doAssert fromTemperature(1700).almostEqual(color(1.0, 0.4728460609912872, 0.0, 1.0))  # Match flame, low pressure sodium lamps (LPS/SOX)
    doAssert fromTemperature(1850).almostEqual(color(1.0, 0.5075678825378418, 0.0, 1.0))  # Candle flame, sunset/sunrise
    doAssert fromTemperature(2400).almostEqual(color(1.0, 0.6151175498962402, 0.2489356100559235, 1.0))  # Standard incandescent lamps
    doAssert fromTemperature(2550).almostEqual(color(1.0, 0.640208899974823, 0.2967877089977264, 1.0))  # Soft white incandescent lamps
    doAssert fromTemperature(2700).almostEqual(color(1.0, 0.6637818813323975, 0.3408890664577484, 1.0))  # "Soft white" compact fluorescent and LED lamps
    doAssert fromTemperature(3000).almostEqual(color(1.0, 0.7068109512329102, 0.4213423728942871, 1.0))  # Warm white compact fluorescent and LED lamps
    doAssert fromTemperature(3200).almostEqual(color(1.0, 0.7327497601509094, 0.4705604314804077, 1.0))  # Studio lamps, photofloods, etc.
    doAssert fromTemperature(3350).almostEqual(color(1.0, 0.7509022951126099, 0.5055340528488159, 1.0))  # Studio "CP" light
    doAssert fromTemperature(5000).almostEqual(color(1.0, 0.8959282636642456, 0.8083687424659729, 1.0))  # Horizon daylight
    doAssert fromTemperature(5000).almostEqual(color(1.0, 0.8959282636642456, 0.8083687424659729, 1.0))  # Tubular fluorescent lamps or cool white
    doAssert fromTemperature(5500).almostEqual(color(1.0, 0.9261417388916016, 0.8775315284729004, 1.0))  # Vertical daylight, electronic flash
    doAssert fromTemperature(6200).almostEqual(color(1.0, 0.9618642926216126, 0.9614840745925903, 1.0))  # Xenon short-arc lamp [2]
    doAssert fromTemperature(6500).almostEqual(color(1.0, 0.9753435850143433, 0.9935365319252014, 1.0))  # Daylight, overcast
    doAssert fromTemperature(6500).almostEqual(color(1.0, 0.9753435850143433, 0.9935365319252014, 1.0))  # LCD or CRT screen
    doAssert fromTemperature(15000).almostEqual(color(0.7009154558181763, 0.7981580495834351, 1.0, 1.0))  # Clear blue poleward sky

suite "premultiplied alpha":
  test "rgba -> rgbx":
    for a in 0.uint8 .. 255:
      for r in 0.uint8 .. 255:
        doAssert rgba(r, 0, 0, a).rgbx == rgbx(
          round(r.float32 * a.float32 / 255).uint8,
          0,
          0,
          a
        )

  test "rgbx -> rgba":
    for a in 0.uint8 .. 255:
      for r in 0.uint8 .. 255:
        let
          rgbx = rgba(r, 0, 0, a).rgbx
          multiplier = round((255 / rgbx.a.float32) * 255).uint32
        doAssert rgbx.rgba == rgba(
          ((rgbx.r * multiplier + 127) div 255).uint8,
          0,
          0,
          rgbx.a.uint8
        )

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
