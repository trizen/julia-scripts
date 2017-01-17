#!/usr/bin/julia

# Daniel "Trizen" Șuteu
# License: GPLv3
# Date: 17 January 2017
# https://github.com/trizen

# Generates the Mandelbrot set.

# See also:
#   https://en.wikipedia.org/wiki/Mandelbrot_set

using Images

@inline function hsv2rgb(h, s, v)
    const c = v * s
    const x = c * (1 - abs(((h/60) % 2) - 1))
    const m = v - c

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

    const r = round(UInt8, (r + m) * 255)
    const g = round(UInt8, (g + m) * 255)
    const b = round(UInt8, (b + m) * 255)

    r,b,g
end

#
## A specific function which maps the value of `c` to some other value.
#
@inline function f(c)
    1/c
end

function mandelbrot()

    const w, h = 1000, 1000

    const zoom  = 1         # the zoom factor
    const moveX = 0         # the amount of shift on the x axis
    const moveY = 0         # the amount of shift on the y axis

    const L = 100           # the maximum value of |z|
    const I = 30            # the maximum number of iterations

    const img = Array(UInt8, h, w, 3)

    for x in 1:w
        for y in 1:h
            const c = Complex(
                (2*x - w) / (w * zoom) + moveX,
                (2*y - h) / (h * zoom) + moveY
            )
            z = c
            n = 0
            while ((n += 1) < I && abs(z) < L)
                z = z^f(c)
            end
            const v = (I - n) / I
            const r,g,b = hsv2rgb(v*360, 1, v)
            img[y,x,1] = r
            img[y,x,2] = g
            img[y,x,3] = b
        end
    end

    println("Generating image...")
    save("$zoom.png", colorim(img, "RGB"))
end

mandelbrot()
