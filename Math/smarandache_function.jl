#!/usr/bin/julia

# Daniel "Trizen" Șuteu
# License: GPLv3
# Date: 17 September 2016
# Website: https://github.com/trizen

# A decently efficient algorithm for computing the results of the Kempner/Smarandache function.

# See also: https://projecteuler.net/problem=549
#           https://en.wikipedia.org/wiki/Kempner_function
#           http://mathworld.wolfram.com/SmarandacheFunction.html

# ∑S(i) for 2 ≤ i ≤ 10^2 == 2012
# ∑S(i) for 2 ≤ i ≤ 10^6 == 64938007616
# ∑S(i) for 2 ≤ i ≤ 10^8 == 476001479068717

function smarandache(n::Int64, cache)

    isprime(n) && return n

    f = factor(n)

    count = 0
    distinct = true
    for v in values(f)
        count += v
        if (distinct && v != 1)
            distinct = false
        end
    end

    distinct && return maximum(keys(f))

    if (length(f) == 1)

        k = collect(keys(f))[1]

        (count <= k) && return k*count

        if haskey(cache, n)
            return cache[n]
        end

        max = k*count
        ff  = factorial(BigInt(max - k))

        while (ff % n == 0)
            max -= k
            ff /= max
        end

        cache[n] = max
        return max
    end

    arr = Int64[]

    for (k,v) in f
        push!(arr, v == 1 ? k : smarandache(k^v, cache))
    end

    maximum(arr)
end

#
## Tests
#

cache = Dict{Int64, Int64}()

limit = 10^2
sumS = 0

for k in 2:limit
    sumS += smarandache(k, cache)
end

println("∑S(i) for 2 ≤ i ≤ $limit == $sumS")

if (limit == 100 && sumS != 2012)
    warn("However that is incorrect! (expected: 2012)")
end
