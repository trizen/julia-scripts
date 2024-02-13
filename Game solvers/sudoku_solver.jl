#!/usr/bin/julia

# Trizen
# Date: 08 February 2017
# https://github.com/trizen

# Recursive brute-force Sudoku solver.

# See also:
#   https://en.wikipedia.org/wiki/Sudoku

function check(i, j)
    id, im = div(i, 9), mod(i, 9)
    jd, jm = div(j, 9), mod(j, 9)

    jd == id && return true
    jm == im && return true

    div(id, 3) == div(jd, 3) &&
    div(jm, 3) == div(im, 3)
end

const lookup = zeros(Bool, 81, 81)

for i in 1:81
    for j in 1:81
        lookup[i,j] = check(i-1, j-1)
    end
end

function solve_sudoku(callback::Function, grid::Array{Int64})
    (function solve()
        for i in 1:81
            if grid[i] == 0
                t = Dict{Int64, Nothing}()

                for j in 1:81
                    if lookup[i,j]
                        t[grid[j]] = nothing
                    end
                end

                for k in 1:9
                    if !haskey(t, k)
                        grid[i] = k
                        solve()
                    end
                end

                grid[i] = 0
                return
            end
        end

        callback(grid)
    end)()
end

function display(grid)
    println("Solution: ")
    for i in 1:length(grid)
        print(grid[i], " ")
        i %  3 == 0 && print(" ")
        i %  9 == 0 && print("\n")
        i % 27 == 0 && print("\n")
    end
end

sudoku_board =
        [2, 0, 0, 0, 7, 0, 0, 0, 3,
         1, 0, 0, 0, 0, 0, 0, 8, 0,
         0, 0, 4, 2, 0, 9, 0, 0, 5,
         9, 4, 0, 0, 0, 0, 6, 0, 8,
         0, 0, 0, 8, 0, 0, 0, 9, 0,
         0, 0, 0, 0, 0, 0, 0, 7, 0,
         7, 2, 1, 9, 0, 8, 0, 6, 0,
         0, 3, 0, 0, 2, 7, 1, 0, 0,
         4, 0, 0, 0, 0, 3, 0, 0, 0]

if false
    sudoku_board = [
         0, 0, 0, 8, 0, 1, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 4, 3,
         5, 0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 7, 0, 8, 0, 0,
         0, 0, 0, 0, 0, 0, 1, 0, 0,
         0, 2, 0, 0, 3, 0, 0, 0, 0,
         6, 0, 0, 0, 0, 0, 0, 7, 5,
         0, 0, 3, 4, 0, 0, 0, 0, 0,
         0, 0, 0, 2, 0, 0, 6, 0, 0
    ]
end

if false
    sudoku_board = [
         8, 0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 3, 6, 0, 0, 0, 0, 0,
         0, 7, 0, 0, 9, 0, 2, 0, 0,
         0, 5, 0, 0, 0, 7, 0, 0, 0,
         0, 0, 0, 0, 4, 5, 7, 0, 0,
         0, 0, 0, 1, 0, 0, 0, 3, 0,
         0, 0, 1, 0, 0, 0, 0, 6, 8,
         0, 0, 8, 5, 0, 0, 0, 1, 0,
         0, 9, 0, 0, 0, 0, 4, 0, 0
    ]
end

solve_sudoku(display, sudoku_board)
