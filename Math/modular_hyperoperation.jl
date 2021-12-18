#!/usr/bin/julia

# Trizen
# Date: 27 August 2016
# https://github.com/trizen

# Generalized implementation of Knuth's up-arrow hyperoperation (modulo some n).

# See also:
#   https://en.wikipedia.org/wiki/Knuth%27s_up-arrow_notation

using Memoize
using Printf

const modulo = 10^3

@memoize function hyper1(n::Int64, k::Int64)
    powermod(n, k, modulo)
end

@memoize function hyper2(n::Int64, k::Int64)
    k <= 1 && return n
    hyper1(n, hyper2(n, k - 1))
end

@memoize function hyper3(n::Int64, k::Int64)
    k <= 1 && return n
    hyper2(n, hyper3(n, k - 1))
end

@memoize function hyper4(n::Int64, k::Int64)
    k <= 1 && return n
    hyper3(n, hyper4(n, k - 1))
end

@memoize function knuth(k::Int64, n::Int64, g::Int64)

    k %= modulo
    g %= modulo

    n >= 1 && g == 0 && return 1

    n == 0 && return ((k * g) % modulo)
    n == 1 && return (hyper1(k, g))
    n == 2 && return (hyper2(k, g))
    n == 3 && return (hyper3(k, g))
    n == 4 && return (hyper4(k, g))

    knuth(k, n - 1, knuth(k, n, g - 1))
end


for i in 0:6
    x = 1 + trunc(Int64, rand()*100)
    y = 1 + trunc(Int64, rand()*100)

    n = knuth(x, i, y)
    @printf("%5s %10s %5s = %5s   (mod %s)\n", x, repeat("^", i), y, n, modulo)
end
