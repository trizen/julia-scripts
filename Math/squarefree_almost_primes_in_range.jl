#!/usr/bin/julia

# Generate squarefree k-almost primes in range [A,B].

# See also:
#   https://en.wikipedia.org/wiki/Almost_prime

using Primes

function big_prod(arr)
    r = big"1"
    for n in (arr)
        r *= n
    end
    return r
end

function squarefree_almost_primes_in_range(A, B, n::Int64)

    A = max(A, big_prod(primes(prime(n))))

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
                lst = vcat(lst, F(m*q, q+1, j-1))
            end
        end

        return lst
    end

    return sort(F(big"1",2,n))
end

# Generate squarefree 5-almost in the range [3000, 10000]

k    = 5
from = 3000
upto = 10000

println(squarefree_almost_primes_in_range(from, upto, k))
