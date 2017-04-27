#!/usr/bin/julia

# Daniel "Trizen" Șuteu
# License: GPLv3
# Date: 27 April 2017
# https://github.com/trizen

# Adds a Mandelbrot-like fractal frame around the edges of an image.

# Usage:
#   julia fractal_frame.jl [image]

using Images
using FileIO

function map_val(value, in_min, in_max, out_min, out_max)
    (value - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

function complex_transform(file)

    const img = load(file)
    const (height, width) = size(img)

    function transform(x, y)

        z = complex(
            (2 * x - width ) / width,
            (2 * y - height) / height
        )

        ok = true
        const c = z

        for i in 1:10

            if (abs(z) > 2)
                ok = false
                break
            end

            z = z^5 + c
        end

        ok ? (real(c), imag(c)) : (Inf, Inf)
    end

    const matrix = zeros(height, width, 2)

    min_x, min_y = (Inf, Inf)
    max_x, max_y = (-Inf, -Inf)

    for y in 1:height
        for x in 1:width
            const (new_x, new_y) = transform(x, y)

            matrix[y,x,1] = new_x
            matrix[y,x,2] = new_y

            if (new_x < min_x && new_x != -Inf)
                min_x = new_x
            end
            if (new_y < min_y && new_y != -Inf)
                min_y = new_y
            end
            if (new_x > max_x && new_x != Inf)
                max_x = new_x
            end
            if (new_y > max_y && new_y != Inf)
                max_y = new_y
            end
        end
    end

    println("X: [$min_x, $max_x]")
    println("Y: [$min_y, $max_y]")

    const out_img = Array{RGB{N0f8}}(height, width)

    for y in 1:height
        for x in 1:width
            new_x = map_val(matrix[y,x,1], min_x, max_x, 1, width)
            new_y = map_val(matrix[y,x,2], min_y, max_y, 1, height)

            if (abs(new_x) == Inf || abs(new_y) == Inf)
                continue
            end

            new_x = round(Int64, new_x)
            new_y = round(Int64, new_y)

            out_img[new_y,new_x] = img[y,x]
        end
    end

    return out_img
end

const file = length(ARGS) > 0 ? ARGS[1] : "input.png"
save("fractal_frame.png", complex_transform(file))
