## CSS has no `fitler: tint()` wich is crazy. But you can emulate tint with other filters.
## For example:
## filter: tint(#00FF00)
## is
## filter: invert(68%) sepia(100%) saturate(4016%) hue-rotate(82deg) brightness(119%) contrast(124%)

import ../chroma, math, os, print, random, strformat, tables
type ColorMatrix = array[0..8, float]

proc clamp(channel: float): float =
  clamp(channel, 0, 1.0)

proc `*`*(color: Color, matrix: ColorMatrix): Color =
  result.r = clamp(color.r * matrix[0] + color.g * matrix[1] + color.b * matrix[2])
  result.g = clamp(color.r * matrix[3] + color.g * matrix[4] + color.b * matrix[5])
  result.b = clamp(color.r * matrix[6] + color.g * matrix[7] + color.b * matrix[8])

proc hueRotate*(color: Color, angle: float): Color =
  var angle = angle / 180 * PI
  let sin = sin(angle)
  let cos = cos(angle)
  color * [
    0.213 + cos * 0.787 - sin * 0.213,
    0.715 - cos * 0.715 - sin * 0.715,
    0.072 - cos * 0.072 + sin * 0.928,
    0.213 - cos * 0.213 + sin * 0.143,
    0.715 + cos * 0.285 + sin * 0.140,
    0.072 - cos * 0.072 - sin * 0.283,
    0.213 - cos * 0.213 - sin * 0.787,
    0.715 - cos * 0.715 + sin * 0.715,
    0.072 + cos * 0.928 + sin * 0.072,
  ]

proc grayscale*(color: Color, value: float): Color =
  let value = value / 100.0
  color * [
    0.2126 + 0.7874 * (1 - value),
    0.7152 - 0.7152 * (1 - value),
    0.0722 - 0.0722 * (1 - value),
    0.2126 - 0.2126 * (1 - value),
    0.7152 + 0.2848 * (1 - value),
    0.0722 - 0.0722 * (1 - value),
    0.2126 - 0.2126 * (1 - value),
    0.7152 - 0.7152 * (1 - value),
    0.0722 + 0.9278 * (1 - value),
  ]

proc sepia*(color: Color, value: float): Color =
  let value = value / 100.0
  color * [
    0.393 + 0.607 * (1 - value),
    0.769 - 0.769 * (1 - value),
    0.189 - 0.189 * (1 - value),
    0.349 - 0.349 * (1 - value),
    0.686 + 0.314 * (1 - value),
    0.168 - 0.168 * (1 - value),
    0.272 - 0.272 * (1 - value),
    0.534 - 0.534 * (1 - value),
    0.131 + 0.869 * (1 - value),
  ]

proc saturate*(color: Color, value: float): Color =
  let value = value / 100.0
  color * [
    0.213 + 0.787 * value,
    0.715 - 0.715 * value,
    0.072 - 0.072 * value,
    0.213 - 0.213 * value,
    0.715 + 0.285 * value,
    0.072 - 0.072 * value,
    0.213 - 0.213 * value,
    0.715 - 0.715 * value,
    0.072 + 0.928 * value,
  ]

proc linear*(color: Color, slope: float, intercept: float): Color =
  result.r = clamp(color.r * slope + intercept)
  result.g = clamp(color.g * slope + intercept)
  result.b = clamp(color.b * slope + intercept)

proc brightness*(color: Color, value: float): Color =
  let value = value / 100.0
  color.linear(value, 0.0)

proc contrast*(color: Color, value: float): Color =
  let value = value / 100.0
  color.linear(value, -(0.5 * value) + 0.5)

proc invert*(color: Color, value: float = 1): Color =
  let value = value / 100
  result.r = clamp(value + color.r * (1 - 2 * value))
  result.g = clamp(value + color.g * (1 - 2 * value))
  result.b = clamp(value + color.b * (1 - 2 * value))

proc dist(a, b: Color): float =
  let
    r = a.r - b.r
    g = a.g - b.g
    b = a.b - b.b
  sqrt(r*r + g*g + b*b)

type Guess = object
  invert, sepia, saturate, hueRotate, brightness, contrast: float
  error: float

proc filter(guess: Guess): string =
  return fmt"""invert({(guess.invert)}%) sepia({(guess.sepia)}%) saturate({(guess.saturate)}%) hue-rotate({(guess.hueRotate)}deg) brightness({(guess.brightness)}%) contrast({(guess.contrast)}%)"""

proc computeColor(guess: Guess): Color =
  color(0.0, 0.0, 0.0, 0.0)
    .invert(guess.invert)
    .sepia(guess.sepia)
    .saturate(guess.saturate)
    .hueRotate(guess.hueRotate)
    .brightness(guess.brightness)
    .contrast(guess.contrast)

proc cssTintFilterGuess(color: Color, accuracy: int): Guess =
  var bestOverallGuess = Guess()
  bestOverallGuess.error = dist(bestOverallGuess.computeColor, color)

  for run in 0..10:
    var bestGuess = Guess()
    bestGuess.invert = 50
    bestGuess.sepia = 50
    bestGuess.saturate = 1000
    bestGuess.hueRotate = 180
    bestGuess.brightness = 50
    bestGuess.contrast = 50
    bestGuess.error = dist(bestGuess.computeColor, color)

    for i in 0..accuracy:
      var s = bestGuess.error * 0.5
      var guess = bestGuess
      guess.invert += float(rand(-100..100)) * s
      guess.sepia += float(rand(-100..100)) * s
      guess.saturate += float(rand(-2000..2000)) * s
      guess.hueRotate += float(rand(-360..360)) * s
      guess.brightness += float(rand(-100..100)) * s
      guess.contrast += float(rand(-100..100)) * s

      guess.invert = clamp(guess.invert, 0, 1E10)
      guess.sepia = clamp(guess.sepia, 0, 1E10)
      guess.saturate = clamp(guess.saturate, 0, 1E10)
      guess.hueRotate = clamp(guess.hueRotate, 0, 1E10)
      guess.brightness = clamp(guess.brightness, 0, 1E10)
      guess.contrast = clamp(guess.contrast, 0, 1E10)

      var currColor = guess.computeColor
      guess.error = dist(currColor, color)
      if bestGuess.error > guess.error:
        bestGuess = guess
        print bestGuess.error, bestGuess.computeColor
      if bestGuess.error < 0.01:
        break

    if bestOverallGuess.error > bestGuess.error:
      bestOverallGuess = bestGuess

  return bestOverallGuess

proc cssTintFilter(color: Color, accuracy: int = 1000): string =
  color.cssTintFilterGuess(accuracy).filter

when isMainModule:
  var color: Color

  color = color(0.0, 0.0, 0.0, 0.0)
  assert color.invert(10).toHtmlRgb() == "rgb(25, 25, 25)"
  assert color.invert(50).toHtmlRgb() == "rgb(127, 127, 127)"
  assert color.invert(90).toHtmlRgb() == "rgb(229, 229, 229)"

  color = color(1.0, 0.0, 0.0, 0.0)
  assert color.sepia(10).toHtmlRgb() == "rgb(239, 8, 6)"
  assert color.sepia(50).toHtmlRgb() == "rgb(177, 44, 34)"
  assert color.sepia(90).toHtmlRgb() == "rgb(115, 80, 62)"

  color = color(1.0, 0.0, 0.0, 0.0)
  assert color.hueRotate(45).toHtmlRgb() == "rgb(157, 41, 0)"
  assert color.hueRotate(180).toHtmlRgb() == "rgb(0, 108, 108)"
  assert color.hueRotate(275).toHtmlRgb() == "rgb(125, 13, 249)"

  color = color(1.0, 0.0, 0.0, 0.0)
  assert color.brightness(10).toHtmlRgb() == "rgb(25, 0, 0)"
  assert color.brightness(50).toHtmlRgb() == "rgb(127, 0, 0)"
  assert color.brightness(90).toHtmlRgb() == "rgb(229, 0, 0)"

  color = color(1.0, 0.0, 0.0, 0.0)
  assert color.contrast(10).toHtmlRgb() == "rgb(140, 114, 114)"
  assert color.contrast(50).toHtmlRgb() == "rgb(191, 63, 63)"
  assert color.contrast(90).toHtmlRgb() == "rgb(242, 12, 12)"

  print cssTintFilter(color(0.0, 0.2, 0.4, 0.0))

  # for i in 0..<1000:
  #   var color = color(rand(1.0), rand(1.0), rand(1.0), 1.0)
  #   echo color.toHtmlHex()
  #   var guess = cssTintFilterGuess(color, 1000)
  #   echo " -> "
  #   echo guess.computeColor.toHtmlHex()
  #   echo " error: "
  #   echo guess.error
  #   echo " filter: "
  #   echo guess.filter
  #   echo "</br>"
  #   echo fmt"<div style='background-color: {color.toHtmlHex()}; width:40px; height:40px; display: inline-block;'></div> "
  #   echo fmt"<img src='https://image.flaticon.com/icons/png/512/38/38546.png' style='filter: {guess.filter}; width:40px; height:40px'></div>"
  #   echo "</br>"

  # for r in 0..255:
  #   for g in 0..255:
  #     for b in 0..255:
  #       var color = color(float(r)/255.0, float(g)/255.0, float(b)/255.0, 1.0)
  #       var guess = cssTintFilterGuess(color, 1000)
  #       echo color.toHtmlHex(), " -> ", guess.computeColor.toHtmlHex(), "[", guess.error, "] f ", guess.filter
