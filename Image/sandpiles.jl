#!/usr/bin/julia

# Simulate the toppling of sandpiles.

# See also:
#   https://en.wikipedia.org/wiki/Abelian_sandpile_model
#   https://www.youtube.com/watch?v=1MtEUErz7Gg -- ‎Sandpiles - Numberphile
#   https://www.youtube.com/watch?v=diGjw5tghYU -- ‎Coding Challenge #107: Sandpiles (by Daniel Shiffman)

using Images

function topple(plane, nextplane, width, height)

    for y in 1:height, x in 1:width
        pile = plane[y,x]

        if (pile < 4)
            nextplane[y,x] = pile
        end
    end

    for y in 2:height-1, x in 2:width-1
        pile = plane[y,x]

        if (pile >= 4)
            nextplane[y, x] += pile - 4
            nextplane[y - 1, x] += 1
            nextplane[y + 1, x] += 1
            nextplane[y, x - 1] += 1
            nextplane[y, x + 1] += 1
        end
    end

    return nextplane
end

function contains_four(plane, width, height)

    for y in 1:height, x in 1:width
        if (plane[y,x] >= 4)
            return true
        end
    end

    return false
end

function sandpiles()

    w, h = 240, 240

    plane = zeros(Int64, h, w)
    plane[div(h,2), div(w,2)] = 10^5

    while (contains_four(plane, w, h))
        nextplane = zeros(Int64, h, w)
        plane = topple(plane, nextplane, w, h)
    end

    colors = [
                RGB{Float64}(0, 0, 0),
                RGB{Float64}(0, 0, 255),
                RGB{Float64}(0, 255, 0),
                RGB{Float64}(255, 255, 255),
            ]

    background = RGB{Float64}(0, 0, 0)
    img = zeros(RGB{Float64}, h, w)

    for y in 1:h, x in 1:w
        pile = plane[y,x]
        col = background

        if (pile <= 3)
            col = colors[pile+1]
        end

        img[y,x] = col
    end

    img = map(clamp01nan, img)

    return img
end

img = sandpiles()
println("Saving image...")
save("sandpiles.png", img)
