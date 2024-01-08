#!/usr/bin/julia

# Trizen
# 14 October 2016
# https://github.com/trizen

# Algorithm from:
#   https://oeis.org/wiki/User:Peter_Luschny/ComputationAndAsymptoticsOfBernoulliNumbers#Seidel

using Printf
const BONE = big"1"

function bernoulli_seidel(n)

    n == 0   && return 1
    n == 1   && return 1//2
    isodd(n) && return 0

    D = append!([0, BONE], [0 for i in 1:(n/2-1)])

    h = 2
    b = false
    for i in 1:n
        if b
            for k in 2:h-1
                D[k] += D[k-1]
            end
        else
            w = h-1
            h += 1
            while w > 1
                D[w] += D[w+1]
                w -= 1
            end
        end
        b = !b
    end

    D[h-1] // ((BONE << (n+1)) - 2) * ((n % 4) == 0 ? -1 : 1)
end

for i in 0:50
    @printf("B%-3d = %s\n", 2*i, bernoulli_seidel(2*i))
end
