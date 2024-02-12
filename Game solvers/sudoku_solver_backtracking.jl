#!/usr/bin/julia

# Author: Trizen
# Date: 12 February 2024
# https://github.com/trizen

# Solve Sudoku puzzle (recursive/backtracking solution).

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

function find_empty_location(board)

    # Find an empty positions (cell with 0)
    for i in 1:9, j in 1:9
        if board[i][j] == 0
            return [i,j]
        end
    end

    return (nothing, nothing)
end

function solve_sudoku(board)

    row, col = find_empty_location(board)

    if (row == nothing && col == nothing)
        return true  # Puzzle is solved
    end

    for num in 1:9
        if is_valid(board, row, col, num)
            # Try placing the number
            board[row][col] = num

            # Recursively try to solve the rest of the puzzle
            if solve_sudoku(board)
                return true
            end

            # If placing the current number doesn't lead to a solution, backtrack
            board[row][col] = 0
        end
    end

    return false  # No solution found
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

solved = solve_sudoku(sudoku_board)

if (solved)
    for row in sudoku_board
        println(row)
    end
else
    println("No solution exists.")
end
