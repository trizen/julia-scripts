#!/usr/bin/julia

# Trizen
# Date: 28 August 2020
# https://github.com/trizen

# A new algorithm for generating Fermat super-pseudoprimes to base 2.

# OEIS:
#   https://oeis.org/A050217 -- Super-Poulet numbers: Poulet numbers whose divisors d all satisfy d|2^d-2.
#   https://oeis.org/A214305 -- Fermat pseudoprimes to base 2 with two prime factors.

# See also:
#   https://en.wikipedia.org/wiki/Fermat_pseudoprime
#   https://trizenx.blogspot.com/2020/08/pseudoprimes-construction-methods-and.html

using Primes
using Combinatorics

function divisors(n)

    d = Int64[1]

    for (p,e) in factor(n)
        t = Int64[]
        r = 1

        for i in 1:e
            r *= p
            for u in d
                push!(t, u*r)
            end
        end

        append!(d, t)
    end

    return d
end

function fermat_pseudoprimes(limit)

    table = Dict{Int64, Array{Int64}}()

    for p in primes(3,limit)
        for d in (divisors(p-1))
            if (powermod(2, d, p) == 1)
                if (haskey(table, d))
                    push!(table[d], p)
                else
                    table[d] = [p]
                end
            end
        end
    end

    for (k,v) in table
        for k in 2:length(v)
            for c in combinations(v,k)
                println(prod(map(x -> BigInt(x), c)))
            end
        end
    end

    return true
end

fermat_pseudoprimes(10^5)
