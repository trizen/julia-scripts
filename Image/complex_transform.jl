#!/usr/bin/julia

# Daniel "Trizen" Șuteu
# License: GPLv3
# Date: 27 April 2017
# https://github.com/trizen

# Complex transform of an image, by mapping each pixel position to a complex function.

# usage:
#   julia complex_transform.jl [image]

using Images
using FileIO
#using SpecialFunctions

function map_val(value, in_min, in_max, out_min, out_max)
    (value - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

function complex_transform(file)

    const img = load(file)
    height, width = size(img)

    function transform(x, y)

        z = complex(
            (2 * x - width ) / width,
            (2 * y - height) / height
        )

        # Complex function
        t = (cos(z) + sin(z)*im) / im

        (real(t), imag(t))
    end

    const matrix = zeros(height, width, 2)

    min_x, min_y = (Inf, Inf)
    max_x, max_y = (-Inf, -Inf)

    for y in 1:height
        for x in 1:width
            new_x, new_y = transform(x, y)

            matrix[y,x,1] = new_x
            matrix[y,x,2] = new_y

            if (new_x < min_x)
                min_x = new_x
            end
            if (new_y < min_y)
                min_y = new_y
            end
            if (new_x > max_x)
                max_x = new_x
            end
            if (new_y > max_y)
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

            if (abs(new_x) == Inf || isnan(new_x) || abs(new_y) == Inf || isnan(new_y))
                println("Skipping one pixel...")
                continue
            end

            new_x = convert(Int64, floor(new_x))
            new_y = convert(Int64, floor(new_y))

            out_img[new_y,new_x] = img[y,x]
        end
    end

    return out_img

end

const file = length(ARGS) > 0 ? ARGS[1] : "input.png"
save("complex_transform.png", complex_transform(file))
