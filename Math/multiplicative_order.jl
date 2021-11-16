#!/usr/bin/julia

# Author: Trizen
# Date: 15 November 2021
# https://github.com/trizen

# Compute the multiplicative order of `a` modulo `n`: znorder(a, n).
# This is the smallest positive integer k such that a^k == 1 (mod n).

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

function znorder(a, n)

    if isprime(n)
        for d in divisors(n-1)
            if (powermod(a, d, n) == 1)
                return d
            end
        end
    end

    f = factor(n)

    if (length(f) == 1)         # is prime power

        p = first(first(f))
        z = znorder(a, p)

        while (powermod(a, z, n) != 1)
            z *= p
        end

        return z
    end

    pp_orders = Int64[]

    for (p,e) in f
        push!(pp_orders, znorder(a, p^e))
    end

    return lcm(pp_orders)
end

isequal(znorder(97, factorial(14)), 25920)          || print("error")
isequal(znorder(53, factorial(15)), 2419200)        || print("error")
isequal(znorder(37, factorial(16)), 116121600)      || print("error")
isequal(znorder(31, factorial(17)), 6220800)        || print("error")
isequal(znorder(89, factorial(18)), 1045094400)     || print("error")
isequal(znorder(101,factorial(19)), 1254113280)     || print("error")
isequal(znorder(97, factorial(20)), 2239488000)     || print("error")

println(znorder(2, 341))        #> 10
println(znorder(97, 5040))      #> 12
