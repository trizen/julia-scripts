#!/usr/bin/julia

# Daniel "Trizen" Șuteu
# Date: 06 September 2022
# Edit: 23 February 2023
# https://github.com/trizen

# Generate all the Carmichael numbers with n prime factors in a given range [a,b]. (not in sorted order)

# See also:
#   https://en.wikipedia.org/wiki/Almost_prime
#   https://trizenx.blogspot.com/2020/08/pseudoprimes-construction-methods-and.html

# PARI/GP program (in range):
#   carmichael(A, B, k) = A=max(A, vecprod(primes(k+1))\2); (f(m, l, p, k, u=0, v=0) = my(list=List()); if(k==1, forprime(p=u, v, my(t=m*p); if((t-1)%l == 0 && (t-1)%(p-1) == 0, listput(list, t))), forprime(q = p, sqrtnint(B\m, k), my(t = m*q); my(L=lcm(l, q-1)); if(gcd(L, t) == 1, my(u=ceil(A/t), v=B\t); if(u <= v, my(r=nextprime(q+1)); if(k==2 && r>u, u=r); list=concat(list, f(t, L, r, k-1, u, v)))))); list); vecsort(Vec(f(1, 1, 3, k)));

using Primes

const BIG = false       # true to use big integers

function big_prod(arr)
    BIG || return prod(arr)
    r = big(1)
    for n in (arr)
        r *= n
    end
    return r
end

function carmichael_numbers_in_range(A, B, k)

    A = max(A, fld(big_prod(primes(prime(k+1))), 2))

    # Largest possible prime factor of Carmichael numbers <= B
    # Proof: By the Chinese Remainder Theorem, if n is a Carmichael number, then:
    #                n == p (mod p*(p-1)), where p is a prime factor of n
    #        therefore `n = p + j*p*(p-1)`, for some j >= 2. (j=1 gives p^2)
    #        With j=2, we have `2*p^2 - p <= n`, hence `p <= (1 + sqrt(8*n + 1))/4`.
    max_p = (1 + isqrt(8*B + 1))>>2

    terms = []

    F = function(m, L, lo, k)

        hi = round(Int64, fld(B, m)^(1/k))

        if (lo > hi)
            return nothing
        end

        if (k == 1)

            hi = min(hi, max_p)
            lo = round(Int64, max(lo, cld(A, m)))
            lo > hi && return nothing

            t = invmod(m, L)
            t > hi && return nothing

            while (t < lo)
                t += L
            end

            for p in t:L:hi
                if (isprime(p))
                    n = m*p
                    if ((n-1) % (p-1) == 0)
                        push!(terms, n)
                    end
                end
            end

            return nothing
        end

        for p in primes(lo, hi)
            if (gcd(m, p-1) == 1)
                F(m*p, lcm(L, p-1), p+1, k-1)
            end
        end
    end

    F((BIG ? big(1) : 1), (BIG ? big(1) : 1), 3, k)

    return sort(terms)
end

# Generate all the Carmichael numbers in range [A,B]
function carmichael(A, B)
    k = 3
    terms = []
    while true

        # Stop when the lower-bound (`primorial(prime(k+1))/2`)  is greater than the upper-limit
        if (big_prod(primes(prime(k+1)))/2 > B)
            break
        end

        append!(terms, carmichael_numbers_in_range(A, B, k))
        k += 1
    end
    return sort(terms)
end

println("=> Carmichael numbers <= 10^6:")
println(carmichael(1, 10^6));

# Generate all the 6-Carmichael numbers in the range [100, 10^10]

k    = 6
from = 100
upto = 10^10

arr = carmichael_numbers_in_range(from, upto, k)

println("\n=> Carmichael numbers with $k prime factors in range [$from, $upto]:")
println(arr)
