#!/usr/bin/julia

# Author: Daniel "Trizen" Șuteu
# License: GPLv3
# Date: 27 March 2016
# Website: https://github.com/trizen

# Generate n random Julia sets as PNG images.

# See also:
#    https://en.wikipedia.org/wiki/Julia_set

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

    (r + m), (b + m), (g + m)
end

function generate(n::Int64)

    const w, h = 1000, 1000

    const zoom  = 0.5
    const moveX = 0
    const moveY = 0
    const maxIter = 50

    const img = Array(RGB{Float64}, h, w)

    for i in 1:n

        const c = Complex(-rand(), 2 * rand() * (rand() < 0.5 ? 1 : -1))

        for x in 1:w
            for y in 1:h
                i = maxIter
                z = Complex(
                    (2*x - w) / (w * zoom) + moveX,
                    (2*y - h) / (h * zoom) + moveY
                )
                while abs(z) < 2 && (i -= 1) > 0
                    z = z*z + c
                end
                const r,g,b = hsv2rgb(i / maxIter * 360, 1, i > 0 ? 1 : 0)
                img[y,x] = RGB{Float64}(r, g, b)
            end
        end

        println("Generating image...")
        save("$c-$zoom.png", img)
    end
end

generate(100)
