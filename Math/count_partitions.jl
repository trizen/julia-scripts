#!/usr/bin/julia

# Trizen
# Date: 18 August 2016
# https://github.com/trizen

# Count the number of partitions of n.

# See also: https://oeis.org/A000041
#           https://en.wikipedia.org/wiki/Partition_(number_theory)

function count_partitions(x::Int64)
    n = 2
    p = Int64[1]

    while (n <= x+1)
        i = 0
        q = 2
        push!(p, 0)

        while q <= n
            p[n] += (i % 4 > 1 ? -1 : 1) * p[n-q+1]
            i += 1
            j = div(i, 2) + 1
            isodd(i) && (j *= -1)
            q = div(j * (3j - 1), 2) + 1
        end

        n += 1
    end

    p[n-1]
end

println("P(200) = ", count_partitions(200))        # 3972999029388
