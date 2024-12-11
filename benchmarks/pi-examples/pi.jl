#!/usr/bin/env julia

using Base.Threads
using LinuxPerf: @pstats

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

using Base.Threads

function _picalc_st_dynamic(numsteps; ntasks=Threads.nthreads())
    slice = 1.0 / numsteps
    n = cld(numsteps, ntasks)

    tasks = map(1:ntasks) do i
        Threads.@spawn begin
            sum_thread = 0.0
            @simd for j in (1 + (i - 1) * n):min(numsteps, i * n)
                x = (j - 0.5) * slice
                sum_thread += 4.0 / (1.0 + x ^ 2)
            end
            sum_thread
        end
    end
    return sum(t -> fetch(t)::Float64, tasks) * slice
end

function _picalc_serial(numsteps)

  slice = 1.0/numsteps

  sum = 0.0

  @simd for i = 1:numsteps
    x = (i - 0.5) * slice
    sum = sum + (4.0/(1.0 + x^2))
  end

  return sum * slice

end

const nthreads_list = (1, 2, 3, 4, 6, 8, 12, 16, 24, 32, 48, 64, 96, 128, 192)

function weak_scaling()
    # warmup
    _picalc(1000)

    open(joinpath(@__DIR__, "weak-scaling.csv"), "w") do file
        base = 1000000000
        println(file, "# threads, number of steps, elapsed time (seconds)")
        for nthreads in nthreads_list
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
        for nthreads in nthreads_list
            # Time in seconds
            time = @elapsed _picalc(numsteps; nthreads)
            @show nthreads, numsteps, time
            println(file, nthreads, ",", numsteps, ",", time)
        end
    end
end

function perf_profile()
    insn = "(cpu-cycles, stalled-cycles-frontend, stalled-cycles-backend),(instructions, branch-misses),(cache-references, cache-misses),(task-clock, page-faults)"
    # warmup
    @pstats insn _picalc(1000)

    open(joinpath(@__DIR__, "perf-profile.log"), "w") do file
        numsteps = 1000000000
        for nthreads in nthreads_list
            stats = @pstats insn _picalc(numsteps; nthreads)
            for io in (stdout, file)
                println(io)
                println(io, "Nthreads = ", nthreads)
                show(io, stats)
                println(io)
            end
        end
    end
end
