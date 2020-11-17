import chroma, chroma/blends

var
  good = 0
  bad = 0

for r in 0 .. 255:
  #for g in 0 .. 255:
  #  for b in 0 .. 255:
      let
        g = 128
        b = 128
      for a in 0 .. 255:
        let
          a = rgba(r.uint8,g.uint8,b.uint8,a.uint8)
          b = rgba(125, 125, 125, 125)
          rgba1 = Normal.mix(a, b)
          rgba2 = Normal.mix(a.color, b.color).rgba

        assert rgba1.a == rgba2.a

        if rgba1 != rgba2:
          #echo "bad  ", a, "mix", b, "=", rgba1, ":", rgba2
          bad += 1
        else:
          #echo "good ", a, "mix", b, "=", rgba1, ":", rgba2
          good += 1

echo "good ", good
echo "bad ", bad
# assert bad <= 1020
