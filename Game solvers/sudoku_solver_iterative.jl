#!/usr/bin/julia

# Author: Trizen
# Date: 12 February 2024
# https://github.com/trizen

# Solve Sudoku puzzle (iterative solution), if it has a unique solution.

function is_valid(board, row, col, num)
    # Check if the number is not present in the current row and column
    for i in 1:9
        if (board[row][i] == num) || (board[i][col] == num)
            return false
        end
    end

    # Check if the number is not present in the current 3x3 subgrid
    start_row, start_col = 3*div(row-1, 3), 3*div(col-1, 3)
    for i in 1:3, j in 1:3
        if board[start_row + i][start_col + j] == num
            return false
        end
    end

    return true
end

function find_empty_locations(board)

    positions = []

    # Find all empty positions (cells with 0)
    for i in 1:9, j in 1:9
        if board[i][j] == 0
            push!(positions, [i, j])
        end
    end

    return positions
end

function solve_sudoku_fallback(board)    # fallback method

    stack = [board]

    while length(stack) >= 1

        current_board   = pop!(stack)
        empty_locations = find_empty_locations(current_board)

        if length(empty_locations) == 0
            return current_board    # solved
        end

        row, col = pop!(empty_locations)

        for num in 1:9
            if is_valid(current_board, row, col, num)
                new_board = deepcopy(current_board)
                new_board[row][col] = num
                push!(stack, new_board)
            end
        end
    end

    return nothing
end

function solve_sudoku(board)

    while true

        empty_locations = find_empty_locations(board)

        if length(empty_locations) == 0
            break   # it's solved
        end

        found = false

        # Solve easy cases
        for (i,j) in empty_locations
            count = 0
            value = 0
            for n in 1:9
                if is_valid(board, i, j, n)
                    count += 1
                    value = n
                    count > 1 && break
                end
            end
            if count == 1
                board[i][j] = value
                found = true
            end
        end

        found && continue

        # Solve more complex cases
        stats = Dict{String,Array}()
        for (i,j) in empty_locations
            arr = []
            for n in 1:9
                if is_valid(board, i, j, n)
                    append!(arr, n)
                end
            end
            stats["$i $j"] = arr
        end

        cols = Dict{String,Int}()
        rows = Dict{String,Int}()

        for (i,j) in empty_locations
            for v in stats["$i $j"]

                k1 = "$j $v"
                k2 = "$i $v"

                if !haskey(cols, k1)
                    cols[k1] = 1
                else
                    cols[k1] += 1
                end

                if !haskey(rows, k2)
                    rows[k2] = 1
                else
                    rows[k2] += 1
                end
            end
        end

        for (i,j) in empty_locations
            for v in stats["$i $j"]
                if (cols["$j $v"] == 1)
                    board[i][j] = v
                    found = true
                elseif (rows["$i $v"] == 1)
                    board[i][j] = v
                    found = true
                end
            end
        end

        found && continue

        # Give up and try brute-force
        return solve_sudoku_fallback(board)
    end

    return board
end

# Example usage:
# Define the Sudoku puzzle as a 9x9 list with 0 representing empty cells
sudoku_board = [
        [2, 0, 0, 0, 7, 0, 0, 0, 3],
        [1, 0, 0, 0, 0, 0, 0, 8, 0],
        [0, 0, 4, 2, 0, 9, 0, 0, 5],
        [9, 4, 0, 0, 0, 0, 6, 0, 8],
        [0, 0, 0, 8, 0, 0, 0, 9, 0],
        [0, 0, 0, 0, 0, 0, 0, 7, 0],
        [7, 2, 1, 9, 0, 8, 0, 6, 0],
        [0, 3, 0, 0, 2, 7, 1, 0, 0],
        [4, 0, 0, 0, 0, 3, 0, 0, 0]
]

solution = solve_sudoku(sudoku_board)

if (solution != nothing)
    for row in solution
        println(row)
    end
else
    println("No unique solution exists.")
end
