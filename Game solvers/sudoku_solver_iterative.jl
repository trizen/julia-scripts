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

function solve_sudoku(board)

    prev_len = 0

    while true

        empty_locations = find_empty_locations(board)

        if length(empty_locations) == 0
            break   # it's solved
        end

        if length(empty_locations) == prev_len
            return nothing   # stuck
        end

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
            end
        end

        prev_len = length(empty_locations)
    end

    return board
end

# Example usage:
# Define the Sudoku puzzle as a 9x9 list with 0 representing empty cells
sudoku_board = [
    [5, 3, 0, 0, 7, 0, 0, 0, 0],
    [6, 0, 0, 1, 9, 5, 0, 0, 0],
    [0, 9, 8, 0, 0, 0, 0, 6, 0],
    [8, 0, 0, 0, 6, 0, 0, 0, 3],
    [4, 0, 0, 8, 0, 3, 0, 0, 1],
    [7, 0, 0, 0, 2, 0, 0, 0, 6],
    [0, 6, 0, 0, 0, 0, 2, 8, 0],
    [0, 0, 0, 4, 1, 9, 0, 0, 5],
    [0, 0, 0, 0, 8, 0, 0, 7, 9]
]

solution = solve_sudoku(sudoku_board)

if (solution != nothing)
    for row in solution
        println(row)
    end
else
    println("No unique solution exists.")
end
