#!/usr/bin/julia

# Sieve for Chernick's "universal form" Carmichael number with n prime factors.
# Inspired by the PARI program by David A. Corneth from OEIS A372238.

# Version with 128-bit integers, to potentially find a(12).

# See also:
#   https://oeis.org/A318646
#   https://oeis.org/A372238/a372238.gp.txt

using Primes

function isrem(m::UInt128, p, n)

    (( 6 * m + 1) % p == 0) && return false
    ((12 * m + 1) % p == 0) && return false
    ((18 * m + 1) % p == 0) && return false

    for k in 2 : n-2
        if (((9 * m << k) + 1) % p == 0)
            return false
        end
    end

    return true
end

function remaindersmodp(p, n)
    filter(m -> isrem(m |> UInt128, p, n), 0:p-1)
end

function mulmod(a::UInt128, b::UInt128, m::Integer)

    # Function from:
    #   https://discourse.julialang.org/t/modular-multiplication-without-overflow/90421/4

    magic1 = (UInt128(0xFFFFFFFF) << 32)
    magic2 = UInt128(0x8000000000000000)

    if iszero(((a | b) & magic1))
        return (a * b) % m
    end

    d = zero(UInt128)
    mp2 = m >> 1

    if a >= m; a %= m; end
    if b >= m; b %= m; end

    for _ in 1:64
        (d > mp2) ? d = ((d << 1) - m) : d = (d << 1)
        if !iszero(a & magic2)
            d += b
        end
        if d >= m
            d -= m
        end
        a <<= 1
    end

    return d
end

function mulmod(a::Integer, b::Integer, m::Integer)
    sa, sb = UInt128.(unsigned.((a,b)))
    return mulmod(sa, sb, m)
end

function chinese(a1, m1, a2, m2)
    M = lcm(m1, m2)
    return [
         (mulmod(mulmod(a1, invmod(div(M, m1), m1), M), div(M, m1), M) +
          mulmod(mulmod(a2, invmod(div(M, m2), m2), M), div(M, m2), M)) % M, M
    ]
end

function remainders_for_primes(n, primes)

    res = [[0, 1]]

    for p in primes

        rems = remaindersmodp(p, n)

        if (length(rems) == 0)
            rems = [0]
        end

        nres = []
        for r in res
            a = r[1]
            m = r[2]
            for rem in rems
                push!(nres, chinese(a, m, rem, p))
            end
        end
        res = nres
    end

    res = map(x -> x[1], res)
    sort!(res)
    return res
end

function is(m::UInt128, n)

    isprime( 6 * m + 1) || return false
    isprime(12 * m + 1) || return false
    isprime(18 * m + 1) || return false

    for k in 2:n-2
        isprime((9 * m << k) + 1) || return false
    end

    return true
end

function deltas(arr)
    prev = 0
    D = []
    for k in arr
        push!(D, k - prev)
        prev = k
    end
    return D
end

function chernick_carmichael_with_n_factors(n)

    maxp = 11

    n >=  8 && (maxp = 17)
    n >= 10 && (maxp = 29)
    n >= 12 && (maxp = 31)

    P = primes(maxp)

    R = remainders_for_primes(n, P)
    D = deltas(R)
    s = prod(P)

    while (D[1] == 0)
        popfirst!(D)
    end

    push!(D, R[1] + s - R[length(R)])

    m      = R[1] |> UInt128
    D_len  = length(D)

    two_power = max(1 << (n - 4), 1)

    for j in 0:10^18

        if (m % two_power == 0 && is(m, n))
            return m |> Int128
        end

        if (j % 10^8 == 0 && j > 0)
            println("Searching for a($n) with m = $m")
        end

        m += D[(j % D_len) + 1]
    end
end

for n in 3:9
    println([n, chernick_carmichael_with_n_factors(n)])
end
