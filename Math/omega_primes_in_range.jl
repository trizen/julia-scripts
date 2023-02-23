#!/usr/bin/julia

# Generate k-omega primes in range [A,B].

# Definition:
#   k-omega primes are numbers n such that omega(n) = k.

# See also:
#   https://en.wikipedia.org/wiki/Almost_prime
#   https://en.wikipedia.org/wiki/Prime_omega_function

using Primes

const BIG = false       # true to use big integers

function big_prod(arr)
    BIG || return prod(arr)
    r = big"1"
    for n in (arr)
        r *= n
    end
    return r
end

function omega_primes_in_range(A, B, n::Int64)

    A = max(A, big_prod(primes(prime(n))))

    F = function(m, lo::Int64, j::Int64)

        lst = []
        hi = round(Int64, fld(B, m)^(1/j))

        if (lo > hi)
            return lst
        end

        for q in (primes(lo, hi))

            v = m*q

            while (v <= B)
                if (j == 1)
                    if (v >= A)
                        push!(lst, v)
                    end
                elseif (v*(q+1) <= B)
                    lst = vcat(lst, F(v, q+1, j-1))
                end
                v *= q
            end
        end

        return lst
    end

    return sort(F((BIG ? big"1" : 1), 2, n))
end

# Generate 5-omega primes in the range [3000, 10000]

k    = 5
from = 3000
upto = 10000

println(omega_primes_in_range(from, upto, k))
