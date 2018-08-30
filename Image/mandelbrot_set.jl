#!/usr/bin/julia

# Daniel "Trizen" Șuteu
# License: GPLv3
# Date: 17 January 2017
# https://github.com/trizen

# Generates the Mandelbrot set.

# See also:
#   https://en.wikipedia.org/wiki/Mandelbrot_set
#   https://trizenx.blogspot.ro/2017/01/mandelbrot-set.html

using Images

@inline function hsv2rgb(h, s, v)
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

    (r + m), (b + m), (g + m)
end

function mandelbrot()

    w, h = 1000, 1000

    zoom  = 0.5
    moveX = 0
    moveY = 0

    img = zeros(RGB{Float64}, h, w)
    maxIter = 100

    for x in 1:w, y in 1:h
        i = maxIter
        c = Complex(
            (2*x - w) / (w * zoom) + moveX,
            (2*y - h) / (h * zoom) + moveY
        )
        z = c
        while abs(z) < 2 && (i -= 1) > 0
            z = z^2 + c
        end
        r,g,b = hsv2rgb(i / maxIter * 360, 1, i / maxIter)
        img[y,x] = RGB{Float64}(r, g, b)
    end

    println("Generating image...")
    save("mandelbrot_set.png", img)
end

mandelbrot()
