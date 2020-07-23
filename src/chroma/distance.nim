## Implementation of CIEDE2000 color difference formula
## 
## See: 
##
##   * https://en.wikipedia.org/wiki/Color_difference#CIEDE2000
##   * http://www2.ece.rochester.edu/~gsharma/ciede2000/ciede2000noteCRNA.pdf

import colortypes, math, transformations

const twentyfiveToSeventh = (25^7).float32

proc myAtan(x, y: float32): float32 =
  if x == 0 and y == 0:
    return 0
  elif x >= 0:
    return arctan2(x, y).radToDeg
  else:
    return arctan2(x, y).radToDeg + 360

func deltaE00*(c1, c2: ColorLAB, kL, kC, kH = 1.float32): float32 =
  let
    C1 = sqrt(c1.a^2 + c1.b^2)
    C2 = sqrt(c2.a^2 + c2.b^2)
    CM = 0.5 * (C1 + C2)
    CM7 = CM^7
    G = 0.5 * (1 - sqrt(CM7 / (CM7 + twentyfiveToSeventh)))
    # aa1 is c1.a prime
    aa1 = (1 + G) * c1.a
    aa2 = (1 + G) * c2.a
    CC1 = sqrt(aa1^2 + c1.b^2)
    CC2 = sqrt(aa2^2 + c2.b^2)
    h1 = myAtan(c1.b, aa1)
    h2 = myAtan(c2.b, aa2)
    deltaL = c2.l - c1.l
    deltaCC = CC2 - CC1
    deltah =
      if CC1 == 0 or CC2 == 0:
        0.float32
      elif abs(h2 - h1) <= 180:
        h2 - h1
      elif h2 - h1 > 180:
        h2 - h1 - 360
      else:
        h2 - h1 + 360
    deltaHH = 2 * sqrt(CC1 * CC2) * sin(degToRad(0.5 * deltah))
    LM = 0.5 * (c1.l + c2.l)
    CCM = 0.5 * (CC1 + CC2)
    hM =
      if CC1 == 0 or CC2 == 0:
        h1 + h2
      elif abs(h2 - h1) <= 180:
        0.5 * (h1 + h2)
      elif h2 - h1 > 180:
        0.5 * (h1 + h2 + 360)
      else:
        0.5 * (h1 + h2 - 360)
    T = 1 - 0.17 * cos(degToRad(hM - 30)) + 0.24 * cos(degToRad(2 * hM)) +
        0.32 * cos(degToRad(3 * hM + 6)) - 0.20 * cos(degToRad(4 * hM - 63))
    deltaTheta = 30 * exp(-1 * ((hM - 275) / 25)^2)
    RC = 2 * sqrt(CCM^7 / (CCM^7 + twentyfiveToSeventh))
    SL = 1 + (0.015 * (LM - 50)^2)/sqrt(20 + (LM - 50)^2)
    SC = 1 + 0.045 * CCM
    SH = 1 + 0.015 * CCM * T
    RT = -sin(degToRad(2 * deltaTheta)) * R_C
  result = sqrt((deltaL/(kL * SL))^2 + (deltaCC/(kC * SC))^2 + (deltaHH/(
      kH * SH))^2 + RT * (deltaCC / (kC * SC)) * (deltaHH/(kH * SH)))
