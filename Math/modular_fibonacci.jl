#!/usr/bin/julia

# Date: 21 August 2016
# https://github.com/trizen

# An efficient algorithm for computing large Fibonacci numbers, modulus some n.
# Algorithm from: http://codeforces.com/blog/entry/14516

function fibmod(n::Int64, mod::Int64)

    n <= 1 && return n
    cache = Dict{Int64, Int64}()

    function f(n::Int64)

        n <= 1           && return 1
        haskey(cache, n) && return cache[n]

        k = div(n, 2)

        cache[n] =
            if n % 2 == 0
                (f(k) * f(k  ) + f(k-1) * f(k-1)) % mod
            else
                (f(k) * f(k+1) + f(k-1) * f(k  )) % mod
            end
    end

    f(n-1)
end

println(fibmod(1000, 10^4))
