#!/usr/bin/julia

# The elliptic-curve factorization method (ECM), due to Hendrik Lenstra.

# Algorithm presented in the YouTube video:
#   https://www.youtube.com/watch?v=2JlpeQWtGH8

# See also:
#   https://en.wikipedia.org/wiki/Lenstra_elliptic-curve_factorization

using Primes

function ecm(N, arange=100, plimit=10000)

    isprime(N) && return N

    # TODO: make sure that N is not a perfect power.

    P = primes(plimit)

    for a in (-arange : arange)

        x = 0
        y = 1

        for B in P
            t = B^trunc(Int64, log(B, plimit))

            (xn, yn) = (0, 0)
            (sx, sy) = (x, y)

            first = true

            while (t > 0)

                if (isodd(t))
                    if (first)
                        (xn, yn) = (sx, sy)
                        first = false
                    else
                        g = gcd(sx-xn, N)

                        if (g > 1)
                            g == N && break
                            return g
                        end

                        u = invmod(sx-xn, N)

                        L  = ((u*(sy-yn)) % N)
                        xs = ((L*L - xn - sx) % N)

                        yn = ((L*(xn - xs) - yn) % N)
                        xn = xs
                    end
                end

                g = gcd(2*sy, N)    # TODO: if N is odd, use gcd(sy, N) instead

                if (g > 1)
                    g == N && break
                    return g
                end

                u = invmod(2*sy, N)

                L  = ((u*(3*sx*sx + a)) % N)
                x2 = ((L*L - 2*sx) % N)

                sy = ((L*(sx - x2) - sy) % N)
                sx = x2

                sy == 0 && return 1
                t >>= 1
            end
            (x, y) = (xn, yn)
        end
    end

    return 1
end

if (length(ARGS) >= 1)
    for n in (ARGS)
        println("One factor of ", n, " is: ", ecm(parse(BigInt, n)))
    end
else
    @time println("One factor of 2^128 + 1 is: ", ecm(big"2"^128 + 1))
end
