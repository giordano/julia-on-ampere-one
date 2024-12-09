#!/usr/bin/env julia

open("hexadecimal-pi.csv", "w") do file
    println(file, "# threads, number of digits, elapsed time (seconds)")
end

# We can't change the number of julia threads at runtime, so we have to spawn a
# separate process for each value of nthreads.
for nthreads in (1, 2, 4, 6, 8, 12, 16, 24, 32, 48, 64, 96, 128, 192)
    run(`$(Base.julia_cmd()) --project=$(@__DIR__) --threads=$(nthreads) hexadecimal-pi.jl 10000`)
end
