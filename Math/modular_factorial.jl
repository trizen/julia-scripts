#!/usr/bin/julia

# Date: 21 August 2016
# https://github.com/trizen

# An efficient algorithm for computing factorial of a large number, modulus a larger number.
# Algorithm from: http://stackoverflow.com/questions/9727962/fast-way-to-calculate-n-mod-m-where-m-is-prime

function facmod(n::Int64, mod::Int64)

    f = 1
    for k in n+1:mod-1
       f *= k
       f %= mod
    end

    (-1 * invmod(f, mod) + mod) % mod
end

println(facmod(100_000_000, 100_000_037))
