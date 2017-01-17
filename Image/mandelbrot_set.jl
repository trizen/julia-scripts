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

function mandelbrot()

    const w, h = 1000, 1000

    const zoom  = 0.5
    const moveX = 0
    const moveY = 0

    const img = Array(UInt8, h, w, 3)
    const maxIter = 100

    for x in 1:w
        for y in 1:h
            i = maxIter
            const c = Complex(
                (2*x - w) / (w * zoom) + moveX,
                (2*y - h) / (h * zoom) + moveY
            )
            z = c
            while abs(z) < 2 && (i -= 1) > 0
                z = z^2 + c
            end
            const r,g,b = hsv2rgb(i / maxIter * 360, 1, i / maxIter)
            img[y,x,1] = r
            img[y,x,2] = g
            img[y,x,3] = b
        end
    end

    println("Generating image...")
    save("$zoom.png", colorim(img, "RGB"))
end

mandelbrot()
