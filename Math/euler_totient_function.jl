#!/usr/bin/julia

# Daniel "Trizen" Șuteu
# License: GPLv3
# Date: 09 November 2016
# Website: https://github.com/trizen

# A simple implementation of Euler's totient function.

# See also:
#   https://www.youtube.com/watch?v=fq6SXByItUI
#   https://en.wikipedia.org/wiki/Euler%27s_totient_function

using Primes

function Φ(n::Int64)

    for p in keys(factor(n))
        n -= div(n, p)
    end

    n
end

# Φ(240) = Φ(2^4 * 3^1 * 5^1)
# Φ(240) = (2^4 - 2^3) * (3^1 - 3^0) * (5^1 - 5^0)
# Φ(240) = 64

println(Φ(240))
