#!/usr/bin/julia

# Generate k-almost primes in range [A,B].

# See also:
#   https://en.wikipedia.org/wiki/Almost_prime

using Primes

const BIG = false       # true to use big integers

function almost_primes_in_range(A, B, n::Int64)

    A = max(A, (BIG ? big"2" : 2)^n)

    F = function(m, lo::Int64, j::Int64)

        lst = []
        hi = round(Int64, fld(B, m)^(1/j))

        if (lo > hi)
            return lst
        end

        if (j == 1)

            lo = round(Int64, max(lo, cld(A, m)))

            if (lo > hi)
                return lst
            end

            for q in (primes(lo, hi))
                push!(lst, m*q)
            end
        else
            for q in (primes(lo, hi))
                lst = vcat(lst, F(m*q, q, j-1))
            end
        end

        return lst
    end

    return sort(F((BIG ? big"1" : 1), 2, n))
end

# Generate 5-almost in the range [300, 1000]

k    = 5
from = 300
upto = 1000

println(almost_primes_in_range(from, upto, k))
