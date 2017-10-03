#!/usr/bin/julia

# Daniel "Trizen" Șuteu
# License: GPLv3
# Date: 17 January 2017
# https://github.com/trizen

# Generates a Mandelbrot-like set.

# See also:
#   https://en.wikipedia.org/wiki/Mandelbrot_set
#   https://trizenx.blogspot.ro/2017/01/mandelbrot-set.html

using Images

@inline function hsv2rgb(h, s, v)
    const c = v * s
    const x = c * (1 - abs(((h/60) % 2) - 1))
    const m = v - c

    const r,g,b =
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

    const img = Array{RGB{Float64}}(h, w)

    for x in 1:w
        for y in 1:h
            const c = Complex(
                (2*x - w) / (w * zoom) + moveX,
                (2*y - h) / (h * zoom) + moveY
            )
            z = c
            n = 0
            q = f(c)
            while (abs(z) < L && (n += 1) < I)
                z = z^q
            end
            const v = (I - n) / I
            const r,g,b = hsv2rgb(v*360, 1, v)
            img[y,x] = RGB{Float64}(r, g, b)
        end
    end

    println("Generating image...")
    save("$zoom.png", img)
end

mandelbrot()
