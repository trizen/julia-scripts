#!/usr/bin/julia

# A simple implementation of the continued fraction factorization method.
# (variation of the Brillhart-Morrison algorithm).

# See also:
#   https://en.wikipedia.org/wiki/Pell%27s_equation
#   https://en.wikipedia.org/wiki/Continued_fraction_factorization
#   https://trizenx.blogspot.com/2018/10/continued-fraction-factorization-method.html

# "Gaussian elimination" algorithm from:
#    https://github.com/martani/Quadratic-Sieve

using Primes

const BIG_ONE  = big"1"
const BIG_ZERO = big"0"

function issquare(n)
    isqrt(n)^2 == n
end

function issquarefree(n)
    for (p,e) in factor(n)
        (e >= 2) && return false
    end
    return true
end

function next_multiplier(n, k)

    k += 2

    while (!issquarefree(k) || gcd(k,n) != 1)
        k += 1
    end

    return k
end

function gaussian_elimination(A, n)

    m = length(A)
    I = [BIG_ONE << k for k in 0:m]

    nrow = 0

    for col in (1 : min(m, n))

        npivot = 0

        for row in (nrow+1 : m)
            if (((A[row] >> (col-1)) & 1) == 1)
                npivot = row
                nrow += 1
                break
            end
        end

        npivot == 0 && continue

        if (npivot != nrow)
            A[[npivot,nrow]] = A[[nrow, npivot]]
            I[[npivot,nrow]] = I[[nrow, npivot]]
        end

        for row in (nrow+1 : m)
            if (((A[row] >> (col-1)) & 1) == 1)
                A[row] = xor(A[row], A[nrow])
                I[row] = xor(I[row], I[nrow])
            end
        end
    end

    return I
end

function check_factor(n, g, factors)

    while (rem(n,g) == 0)

        n = div(n,g)
        push!(factors, g)

        if (isprime(n))
            push!(factors, n)
            return 1
        end
    end

    return n
end

function is_smooth_over_prod(n, k)

    g = gcd(n, k)

    while (g > 1)
        n = div(n, g)
        while (rem(n, g) == 0)
            n = div(n, g)
        end
        n == 1 && return true
        g = gcd(n, g)
    end

    n == 1
end

function jacobi(a, n)
    a %= n
    result = 1
    while a != 0
        while iseven(a)
            a >>= 1
            ((n % 8) in [3, 5]) && (result *= -1)
        end
        a, n = n, a
        (a % 4 == n % 4 == 3) && (result *= -1)
        a %= n
    end
    return n == 1 ? result : 0
end

function cffm(n, multiplier = 1)

    n <= 1     && return []
    isprime(n) && return [n]

    if (iseven(n))

        v = 0
        while (iseven(n))
            v += 1
            n >>= 1
        end

        arr1 = [big"2" for i in 1:v]
        arr2 = cffm(n)

        return append!(arr1, arr2)
    end

    if (issquare(n))
        f = cffm(isqrt(n))
        append!(f, f)
        return sort(f)
    end

    N = n*multiplier

    x = isqrt(N)
    y = x
    z = 1
    w = x+x
    r = w

    nf = round(Int64, exp(sqrt(log(n) * log(log(n))))^(sqrt(2) / 4) / 1.25)
    factor_base = [2]

    begin
        p = 3
        while (length(factor_base) < nf)
            if (jacobi(N, p) >= 0)
                push!(factor_base, p)
            end
            p = nextprime(p+1)
        end
    end

    # ~ B = round(Int64, exp(sqrt(log(n) * log(log(n))) / 2))
    # ~ factor_base = []

    # ~ for p in (primes(B))
        # ~ if (jacobi(N,p) >= 0)
            # ~ push!(factor_base, p)
        # ~ end
    # ~ end

    factor_prod  = prod([big(k) for k in factor_base])
    factor_index = Dict{Int64, Int64}()

    for k in (1:length(factor_base))
        factor_index[factor_base[k]] = k-1
    end

    function exponent_signature(factors)
        sig = BIG_ZERO

        for (p,e) in factors
            if (isodd(e))
                sig |= (BIG_ONE << factor_index[p])
            end
        end

        return sig
    end

    L = length(factor_base)+1

    Q = []
    A = []

    (f1, f2) = (BIG_ONE, x)

    while (length(A) < L)

        y = (r*z - y)
        z = div((N - y*y), z)
        r = div((x + y), z)

        (f1, f2) = (f2, rem((r*f2 + f1), n))

        if (issquare(z))
            g = gcd(f1 - isqrt(z), n)

            if (g > 1 && g < n)
                arr1 = cffm(g)
                arr2 = cffm(div(n,g))
                return sort(append!(arr1, arr2))
            end
        end

        if (z > 1 && is_smooth_over_prod(z, factor_prod))
            push!(A, exponent_signature(factor(z)))
            push!(Q, [f1, z])
        end

        if (z == 1)
            println("z == 1 -> trying again with a multiplier...")
            return cffm(n, next_multiplier(n, multiplier))
        end
    end

    while (length(A) < L)
        push!(A, 0)
    end

    I = gaussian_elimination(A, length(A))

    LR = 0
    for k in (length(A):-1:1)
        if (A[k] != 0)
            LR = k+1
            break
        end
    end

    remainder = n
    factors   = []

    function cfrac_find_factors(solution)

        X = BIG_ONE
        Y = BIG_ONE

        for i in 0:length(Q)-1
            if (((solution >> i) & 1) == 1)

                X *= Q[i+1][1]
                Y *= Q[i+1][2]

                X %= remainder

                g = gcd(X - isqrt(Y), remainder)

                if (g > 1 && g < remainder)

                    remainder = check_factor(remainder, g, factors)

                    if (remainder == 1)
                        return true
                    end
                end
            end
        end

        return false
    end

    for k in LR:length(I)
        cfrac_find_factors(I[k]) && break
    end

    final_factors = []

    for f in (factors)
        if (isprime(f))
            push!(final_factors, f)
        else
            append!(final_factors, cffm(f))
        end
    end

    if (remainder != 1)
        if (remainder != n)
            append!(final_factors, cffm(remainder))
        else
            push!(final_factors, remainder)
        end
    end

    # Failed to factorize n (try again with a multiplier)
    if (remainder == n)
        println("Trying again with a multiplier...")
        return cffm(n, next_multiplier(n, multiplier))
    end

    # Return all prime factors of n
    return sort(final_factors)
end

if (length(ARGS) >= 1)
    for n in (ARGS)
        println(n, " = ", cffm(parse(BigInt, n)))
    end
else
    @time println("2^128 + 1 = ", cffm((big"2")^128 + 1))
end
