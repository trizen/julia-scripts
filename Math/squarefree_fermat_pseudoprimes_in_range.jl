#!/usr/bin/julia

# Daniel "Trizen" Șuteu
# Date: 06 September 2022
# https://github.com/trizen

# Generate all the squarefree Fermat pseudoprimes to given a base with n prime factors in a given range [A,B]. (not in sorted order)

# See also:
#   https://en.wikipedia.org/wiki/Almost_prime
#   https://trizenx.blogspot.com/2020/08/pseudoprimes-construction-methods-and.html

# PARI/GP program (in range [A, B]):
#   squarefree_fermat(A, B, k, base=2) = A=max(A, vecprod(primes(k))); (f(m, l, p, k, u=0, v=0) = my(list=List()); if(k==1, forprime(p=u, v, if(base%p != 0, my(t=m*p); if((t-1)%l == 0 && (t-1)%znorder(Mod(base, p)) == 0, listput(list, t)))), forprime(q = p, sqrtnint(B\m, k), my(t = m*q); if (base%q != 0, my(L=lcm(l, znorder(Mod(base, q)))); if(gcd(L, t) == 1, my(u=ceil(A/t), v=B\t); if(u <= v, my(r=nextprime(q+1)); if(k==2 && r>u, u=r); list=concat(list, f(t, L, r, k-1, u, v))))))); list); vecsort(Vec(f(1, 1, 2, k)));

using Primes

const BIG = false    # true to use big integers

function divisors(n)

    d = Int64[1]

    for (p,e) in factor(n)
        t = Int64[]
        r = 1

        for i in 1:e
            r *= p
            for u in d
                push!(t, u*r)
            end
        end

        append!(d, t)
    end

    sort!(d)
    return d
end

function prime_znorder(a, n)
    for d in divisors(n-1)
        if (powermod(a, d, n) == 1)
            return d
        end
    end
end

function big_prod(arr)
    BIG || return prod(arr)
    r = big"1"
    for n in (arr)
        r *= n
    end
    return r
end

function squarefree_fermat_pseudoprimes_in_range(A, B, k, base, callback)

    A = max(A, big_prod(primes(prime(k))))

    F = function(m, L, lo::Int64, k::Int64)

        hi = round(Int64, fld(B, m)^(1/k))

        if (lo > hi)
            return nothing
        end

        if (k == 1)

            lo = round(Int64, max(lo, cld(A, m)))
            lo > hi && return nothing

            t = invmod(m, L)
            t > hi && return nothing

            while (t < lo)
                t += L
            end

            for p in t:L:hi
                if (isprime(p) && base%p != 0)
                    n = m*p
                    if ((n-1) % prime_znorder(base, p) == 0)
                        callback(n)
                    end
                end
            end

            return nothing
        end

        for p in primes(lo, hi)

            if (base % p != 0)

                z = prime_znorder(base, p)

                if (gcd(m, z) == 1)
                    F(m*p, lcm(L, z), p+1, k-1)
                end
            end
        end
    end

    F((BIG ? big"1" : 1), (BIG ? big"1" : 1), 2, k)
end

# Generate all the 6-Fermat pseudoprimes to base 2 in the range [100, 10^9]

k    = 6
base = 2
from = 100
upto = 10^9

arr = []
squarefree_fermat_pseudoprimes_in_range(from, upto, k, base, function (n) push!(arr, n) end)

sort!(arr)
println(arr)
