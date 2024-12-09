#!/usr/bin/env julia

using LinearAlgebra: BLAS, peakflops

open(joinpath(@__DIR__, "peakflops.csv"), "w") do file
    println(file, "# threads, N, FLOPS")

    for nthreads in (1, 2, 3, 4, 6, 8, 12, 16, 24, 32, 48, 64, 96, 128, 192)
        BLAS.set_num_threads(nthreads)
        # Make sure the setting was effective
        @assert BLAS.get_num_threads() == nthreads

        N = 2 ^ 13
        flops = peakflops(N)

        @show nthreads, N, flops
        println(file, nthreads, ",", N, ",", flops)
    end
end
