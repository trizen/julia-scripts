#!/usr/bin/julia

# Author: Trizen
# Date: 17 December 2023
# https://github.com/trizen

# Generate the entire sequence of both-truncatable primes in a given base.

# Maximum value for each base is given in the following OEIS sequence:
#   https://oeis.org/A323137

# Total number of primes that are both left-truncatable and right-truncatable in base n:
#   https://oeis.org/A323390

# See also:
#   https://www.youtube.com/watch?v=azL5ehbw_24
#   https://en.wikipedia.org/wiki/Truncatable_prime

# Related sequences:
#  https://oeis.org/A076586 - Total number of right truncatable primes in base n.
#  https://oeis.org/A076623 - Total number of left truncatable primes (without zeros) in base n.
#  https://oeis.org/A323390 - Total number of primes that are both left-truncatable and right-truncatable in base n.
#  https://oeis.org/A323396 - Irregular array read by rows, where T(n, k) is the k-th prime that is both left-truncatable and right-truncatable in base n.

using Primes
using Printf

function is_left_truncatable(n::BigInt, base::Int64)

    r = big(base)

    while (r < n)
        isprime(n - r*div(n,r)) || return false
        r = r*base
    end

    return true
end

function generate_from_prefix(p::BigInt, base::Int64)

    seq = [p]

    for d in 1:base-1
        n = p*base + d
        if isprime(n)
            append!(seq, filter(x -> is_left_truncatable(x, base), generate_from_prefix(n, base)))
        end
    end

    return seq
end

function both_truncatable_primes_in_base(base::Int64)

    if (base <= 2)
        return []
    end

    truncatable = []
    for p in primes(2, base-1)
        append!(truncatable, generate_from_prefix(big(p), base))
    end

    return sort(truncatable)
end

for base in 3:36
    t = both_truncatable_primes_in_base(base)
    @printf("There are %3d both-truncatable primes in base %2d where largest is %d\n", length(t), base, last(t))
end
