#!/usr/bin/julia

# Trizen
# 28 August 2020
# https://github.com/trizen

# Generate all the positive divisors of n.

using Primes

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

    return sort(d)
end

println(divisors(5040))
