#!/usr/bin/env julia

using Base.Threads

function _picalc(numsteps; nthreads=Threads.nthreads())
    slice = 1.0 / numsteps

    sums = zeros(Float64, nthreads)
    n = cld(numsteps, nthreads)

    Threads.@threads :static for i in 1:nthreads
        sum_thread = 0.0
        @simd for j in (1 + (i - 1) * n):min(numsteps, i * n)
            x = (j - 0.5) * slice
            sum_thread += 4.0 / (1.0 + x ^ 2)
        end
        sums[threadid()] = sum_thread
    end

    return sum(sums) * slice
end

function weak_scaling()
    # warmup
    _picalc(1000)

    open(joinpath(@__DIR__, "weak-scaling.csv"), "w") do file
        base = 1000000000
        println(file, "# threads, number of steps, elapsed time (seconds)")
        for nthreads in (1, 2, 3, 4, 6, 8, 12, 16, 24, 32, 48, 64, 96, 128, 192)
            numsteps = nthreads * base
            # Time in seconds
            time = @elapsed _picalc(numsteps; nthreads)
            @show nthreads, numsteps, time
            println(file, nthreads, ",", numsteps, ",", time)
        end
    end
end

function strong_scaling()
    # warmup
    _picalc(1000)

    open(joinpath(@__DIR__, "strong-scaling.csv"), "w") do file
        numsteps = 1000000000
        println(file, "# threads, number of steps, elapsed time (seconds)")
        for nthreads in (1, 2, 3, 4, 6, 8, 12, 16, 24, 32, 48, 64, 96, 128, 192)
            # Time in seconds
            time = @elapsed _picalc(numsteps; nthreads)
            @show nthreads, numsteps, time
            println(file, nthreads, ",", numsteps, ",", time)
        end
    end
end
