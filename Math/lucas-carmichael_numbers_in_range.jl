#!/usr/bin/julia

# Daniel "Trizen" Șuteu
# Date: 06 September 2022
# https://github.com/trizen

# Generate all the Lucas-Carmichael numbers with n prime factors in a given range [a,b]. (not in sorted order)

# See also:
#   https://en.wikipedia.org/wiki/Almost_prime
#   https://trizenx.blogspot.com/2020/08/pseudoprimes-construction-methods-and.html

# PARI/GP program (in range [A,B]):
#   lucas_carmichael(A, B, k) = A=max(A, vecprod(primes(k+1))\2); (f(m, l, p, k, u=0, v=0) = my(list=List()); if(k==1, forprime(p=u, v, my(t=m*p); if((t+1)%l == 0 && (t+1)%(p+1) == 0, listput(list, t))), forprime(q = p, sqrtnint(B\m, k), my(t = m*q); my(L=lcm(l, q+1)); if(gcd(L, t) == 1, my(u=ceil(A/t), v=B\t); if(u <= v, my(r=nextprime(q+1)); if(k==2 && r>u, u=r); list=concat(list, f(t, L, r, k-1, u, v)))))); list); vecsort(Vec(f(1, 1, 3, k)));

using Primes

function lucas_carmichael_numbers_in_range(A, B, k, callback)

    A = max(A, fld(prod(primes(prime(k+1))), 2))

    F = function(m, L, lo, k)

        hi = round(Int64, fld(B, m)^(1/k))

        if (lo > hi)
            return nothing
        end

        if (k == 1)

            lo = round(Int64, max(lo, cld(A, m)))

            if (lo > hi)
                return nothing
            end

            for p in (primes(lo, hi))
                t = m*p
                if ((t+1) % L == 0 && (t+1) % (p+1) == 0)
                    callback(t)
                end
            end

            return nothing
        end

        for p in (primes(lo, hi))
            t = lcm(L, p+1)

            if (gcd(t, m) == 1)
                F(m*p, t, p+1, k-1)
            end
        end
    end

    F(1, 1, 3, k)
end

# Generate all the 6-Lucas-Carmichael numbers in the range [100, 10^10]

k    = 6
from = 100
upto = 10^10

arr = []
lucas_carmichael_numbers_in_range(from, upto, k, function (n) push!(arr, n) end)

sort!(arr)
println(arr)
