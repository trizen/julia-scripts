#!/usr/bin/julia

# Daniel "Trizen" Șuteu
# Date: 07 March 2023
# https://github.com/trizen

# Generate all the Fermat pseudoprimes to given a base with n prime factors in a given range [A,B]. (not in sorted order)

# See also:
#   https://en.wikipedia.org/wiki/Almost_prime
#   https://trizenx.blogspot.com/2020/08/pseudoprimes-construction-methods-and.html

# PARI/GP program (slow):
#   fermat_psp(A, B, k, base) = A=max(A, vecprod(primes(k))); (f(m, l, p, j) = my(list=List()); forprime(q=p, sqrtnint(B\m, j), if(base%q != 0, my(v=m*q, t=q, r=nextprime(q+1)); while(v <= B, my(L=lcm(l, znorder(Mod(base, t)))); if(gcd(L, v) == 1, if(j==1, if(v>=A && if(k==1, !isprime(v), 1) && (v-1)%L == 0, listput(list, v)), if(v*r <= B, list=concat(list, f(v, L, r, j-1)))), break); v *= q; t *= q))); list); vecsort(Vec(f(1, 1, 2, k)));

# PARI/GP program (fast):
#   fermat_psp(A, B, k, base) = A=max(A, vecprod(primes(k))); (f(m, l, lo, k) = my(list=List()); my(hi=sqrtnint(B\m, k)); if(lo > hi, return(list)); if(k==1, forstep(p=lift(1/Mod(m, l)), hi, l, if(isprimepower(p) && gcd(m*base, p) == 1, my(n=m*p); if(n >= A && (n-1) % znorder(Mod(base, p)) == 0, listput(list, n)))), forprime(p=lo, hi, base%p == 0 && next; my(z=znorder(Mod(base, p))); gcd(m,z) == 1 || next; my(q=p, v=m*p); while(v <= B, list=concat(list, f(v, lcm(l, z), p+1, k-1)); q *= p; Mod(base, q)^z == 1 || break; v *= p))); list); vecsort(Set(f(1, 1, 2, k)));

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

    return sort(d)
end

function isprimepower(n)
    length(factor(n)) == 1
end

function znorder(a, n)

    if isprime(n)
        for d in divisors(n-1)
            if (powermod(a, d, n) == 1)
                return d
            end
        end
    end

    f = factor(n)

    if (length(f) == 1)         # is prime power

        p = first(first(f))
        z = znorder(a, p)

        while (powermod(a, z, n) != 1)
            z *= p
        end

        return z
    end

    pp_orders = Int64[]

    for (p,e) in f
        push!(pp_orders, znorder(a, p^e))
    end

    return lcm(pp_orders)
end

function big_prod(arr)
    BIG || return prod(arr)
    r = big"1"
    for n in (arr)
        r *= n
    end
    return r
end

function fermat_pseudoprimes_in_range(A, B, k, base, callback)

    seen = Dict()
    A = max(A, big_prod(primes(prime(k))))

    F = function(m, L, lo::Int64, k::Int64)

        hi = round(Int64, fld(B, m)^(1/k))

        if (lo > hi)
            return nothing
        end

        if (k == 1)

            if (L == 1)
                for p in primes(lo, hi)
                    base % p == 0 && continue
                    v = (m == 1 ? p*p : m*p)
                    while (v <= B)
                        if (v >= A)
                            powermod(base, v-1, v) == 1 || break
                            if (!haskey(seen, v))
                                callback(v)
                                seen[v] = true
                            end
                        end
                        v *= p
                    end
                end
                return nothing
            end

            t = invmod(m, L)
            t > hi && return nothing

            if (t < lo)
                t += L*cld(lo - t, L)
            end

            t > hi && return nothing

            for p in t:L:hi
                if (isprimepower(p) && gcd(m, p) == 1 && gcd(base, p) == 1)
                    n = m*p
                    if (n >= A && (n-1) % znorder(base, p) == 0)
                        if (!haskey(seen, n))
                            callback(n)
                            seen[n] = true
                        end
                    end
                end
            end

            return nothing
        end

        for p in primes(lo, hi)

            if (base % p != 0)

                z = znorder(base, p)

                if (gcd(m, z) == 1)
                    v = m*p
                    q = p
                    while (v <= B)
                        F(v, lcm(L, z), p+1, k-1)
                        q *= p
                        powermod(base, z, q) == 1 || break
                        v *= p
                    end
                end
            end
        end
    end

    F((BIG ? big"1" : 1), (BIG ? big"1" : 1), 2, k)
end

# Generate all the Fermat pseudoprimes to base 3 in range [1, 10^5]

from = 1
upto = 10^5
base = 3

arr = []

for k in 1:100
    prod(primes(prime(k))) > upto && break
    fermat_pseudoprimes_in_range(from, upto, k, base, function (n) push!(arr, n) end)
end

sort!(arr)
println(arr)
