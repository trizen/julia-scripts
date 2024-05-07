#!/usr/bin/julia

# Trizen
# Date: 11 June 2019
# https://github.com/trizen

# Generate the smallest extended Chernick-Carmichael number with n prime factors.

# Takes ~7 minutes to find a(10).

# OEIS sequence:
#   https://oeis.org/A318646 -- The least Chernick's "universal form" Carmichael number with n prime factors.

# See also:
#   https://oeis.org/wiki/Carmichael_numbers
#   https://www.ams.org/journals/bull/1939-45-04/S0002-9904-1939-06953-X/home.html

using Primes

function trial_pretest(k::UInt64)

    if ((k %  3)==0 || (k %  5)==0 || (k %  7)==0 || (k % 11)==0 ||
        (k % 13)==0 || (k % 17)==0 || (k % 19)==0 || (k % 23)==0)
        return (k <= 23)
    end

    return true
end

function gcd_pretest(k::UInt64)

    if (k <= 107)
        return true
    end

    gcd(29*31*37*41*43*47*53*59*61*67, k) == 1 &&
    gcd(71*73*79*83*89*97*101*103*107, k) == 1
end

function is_chernick(n::Int64, m::UInt64)

    t = 9*m

    if (!trial_pretest(6*m + 1))
        return false
    end

    if (!trial_pretest(12*m + 1))
        return false
    end

    for i in 1:n-2
        if (!trial_pretest((t << i) + 1))
            return false
        end
    end

    if (!gcd_pretest(6*m + 1))
        return false
    end

    if (!gcd_pretest(12*m + 1))
        return false
    end

    for i in 1:n-2
        if (!gcd_pretest((t << i) + 1))
            return false
        end
    end

    if (!isprime(6*m + 1))
        return false
    end

    if (!isprime(12*m + 1))
        return false
    end

    for i in 1:n-2
        if (!isprime((t << i) + 1))
            return false
        end
    end

    return true
end

function chernick_carmichael(n::Int64, m::UInt64)
    prod = big(1)

    prod *= 6*m + 1
    prod *= 12*m + 1

    for i in 1:n-2
        prod *= ((big(9)*m)<<i) + 1
    end

    prod
end

function cc_numbers(from, to)

    for n in from:to

        multiplier = 1

        if (n > 4) multiplier = 1 << (n-4) end
        if (n > 5) multiplier *= 5 end

        m = UInt64(multiplier)

        while true

            if (is_chernick(n, m))
                println("a(", n, ") = ", chernick_carmichael(n, m))
                break
            end

            m += multiplier
        end
    end
end

cc_numbers(3, 9)

# Terms a(3)-a(10):

#   a(3) = 1729
#   a(4) = 63973
#   a(5) = 26641259752490421121
#   a(6) = 1457836374916028334162241
#   a(7) = 24541683183872873851606952966798288052977151461406721
#   a(8) = 53487697914261966820654105730041031613370337776541835775672321
#   a(9) = 58571442634534443082821160508299574798027946748324125518533225605795841
#   a(10) = 24616075028246330441656912428380582403261346369700917629170235674289719437963233744091978433592331048416482649086961226304033068172880278517841921
