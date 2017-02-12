#!/usr/bin/julia

# Daniel "Trizen" Șuteu
# License: GPLv3
# Date: 12 February 2017
# https://github.com/trizen

# Implementation of the sigma function (sum of the divisors).

# See also:
#    https://en.wikipedia.org/wiki/Divisor_function

using Primes

function divisor_sum(n, x=1)
    sigma = 1
    f = factor(n)
    for p in keys(f)
        s = 1
        for j in 1:f[p]
            s += p^(j*x)
        end
        sigma *= s
    end
    sigma
end

println(divisor_sum(1234))        # 1854
println(divisor_sum(99000))       # 365040
println(divisor_sum(99000, 2))    # 15359172920
