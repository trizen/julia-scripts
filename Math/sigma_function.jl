#!/usr/bin/julia

# Trizen
# Date: 12 February 2017
# https://github.com/trizen

# Implementation of the sigma function (sum of the divisors).

# See also:
#    https://en.wikipedia.org/wiki/Divisor_function

using Primes

function divisor_sum(n, x=1)

    if (x == 0)     # optimization
        tau = 1
        for (p,e) in factor(n)
            tau *= (e+1)
        end
        return tau
    end

    sigma = 1
    for (p,e) in factor(n)
        s = 1
        q = p^x
        for j in 1:e
            s += q^j
        end
        sigma *= s
    end

    return sigma
end

println(divisor_sum(5040, 0))     # 60
println(divisor_sum(1234))        # 1854
println(divisor_sum(99000))       # 365040
println(divisor_sum(99000, 2))    # 15359172920
