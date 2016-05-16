#!/usr/bin/julia

# Author: Daniel "Trizen" Șuteu
# License: GPLv3
# Date: 27 March 2016
# Website: https://github.com/trizen

# Generate 100 random Julia sets as PNG images.
# See also: https://en.wikipedia.org/wiki/Julia_set

using Images

w, h = 800, 600

zoom = 1
moveX = 0
moveY = 0

img = Array(UInt8, h, w, 3)

function hsv2rgb(h, s, v)
    c = v * s
    x = c * (1 - abs(((h/60) % 2) - 1))
    m = v - c

    r,g,b =
        if h < 60
            (c, x, 0)
        elseif h < 120
            (x, c, 0)
        elseif h < 180
            (0, c, x)
        elseif h < 240
            (0, x, c)
        elseif h < 300
            (x, 0, c)
        else
            (c, 0, x)
        end

    r = round(UInt8, (r + m) * 255)
    g = round(UInt8, (g + m) * 255)
    b = round(UInt8, (b + m) * 255)

    r,b,g
end

for i in 1:100

    maxIter = 50
    c = Complex(-rand(), 2 * rand() * (rand() < 0.5 ? 1 : -1))

    for x in 1:w
        for y in 1:h
            i = maxIter
            z = Complex(
                3/2 * (2*x - w) / (w * zoom) + moveX,
                      (2*y - h) / (h * zoom) + moveY
            )
            while abs(z) < 2 && (i -= 1) > 0
                z = z*z + c
            end
            r,g,b = hsv2rgb(i / maxIter * 360, 1, i > 0 ? 1 : 0)
            img[y,x,1] = r
            img[y,x,2] = g
            img[y,x,3] = b
        end
    end

    println("Generating image...")
    save("$c-$zoom.png", colorim(img, "RGB"))
end
