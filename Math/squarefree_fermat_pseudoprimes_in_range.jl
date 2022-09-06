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

function squarefree_fermat_pseudoprimes_in_range(A, B, k, base, callback)

    A = max(A, fld(prod(primes(prime(k+1))), 2))

    F = function(m, lambda, p, k, u, v)

        if (u > v)
            return nothing
        end

        if (k == 1)

            p = nextprime(u)

            while (p <= v)
                t = m*p
                if ((t-1) % lambda == 0 && (t-1) % prime_znorder(base, p) == 0)
                    callback(t)
                end
                p = nextprime(p+1)
            end

            return nothing
        end

        s = round(Int64, fld(B, m)^(1/k))

        while (p <= s)

            r = nextprime(p+1)

            if (base % p != 0)

                L = lcm(lambda, prime_znorder(base, p))

                if (gcd(L, m) == 1)

                    t = m*p
                    u = cld(A, t)
                    v = fld(B, t)

                    if (u <= v)
                        if (k == 2 && r > u)
                            u = r
                        end
                        F(t, L, r, k - 1, u, v)
                    end
                end
            end

            p = r
        end
    end

    F(1, 1, 3, k, 1, 1)
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
