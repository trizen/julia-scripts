#!/usr/bin/julia

# Author: Daniel "Trizen" Șuteu
# Date: 19 August 2016
# License: GPLv3
# Website: https://github.com/trizen

# Count the number of partitions of n, using a recursive relation.

# See also: https://oeis.org/A000041
#           https://en.wikipedia.org/wiki/Partition_(number_theory)

function partitions_count(n::Int64, cache::Dict{Int,Int})

    n <= 1 && return n

    if haskey(cache, n)
        return cache[n]
    end

    sum_1 = 0
    for i in 1:Int64(floor((sqrt(24*n + 1) + 1)/6))
        sum_1 += ((-1)^(i-1) * partitions_count(n - div(i*(3*i - 1), 2), cache))
    end

    sum_2 = 0
    for i in 1:Int64(ceil((sqrt(24*n + 1) - 7)/6))
        sum_2 += ((-1)^(i-1) * partitions_count(n - div((-i) * (-3*i - 1), 2), cache))
    end

    x = (sum_1 + sum_2)
    cache[n] = x
    x
end

println("P(200) = ", partitions_count(200+1, Dict{Int64, Int64}()))        # 3972999029388
