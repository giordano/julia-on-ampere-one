#!/usr/bin/env julia

using Base.Threads
using LinuxPerf: @pstats

using ThreadPinning: pinthreads

function _kernel(i, n, numsteps, slice)
    sum_thread = 0.0
    @simd for j in (1 + (i - 1) * n):min(numsteps, i * n)
        x = (j - 0.5) * slice
        sum_thread += 4.0 / (1.0 + x ^ 2)
    end
    return sum_thread
end

function _picalc(numsteps; nthreads=Threads.nthreads())
    slice = 1.0 / numsteps

    sums = zeros(Float64, nthreads)
    n = cld(numsteps, nthreads)

    Threads.@threads :static for i in 1:nthreads
        @inbounds sums[i] = _kernel(i, n, numsteps, 1.0 / numsteps)
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

function weak_scaling(; pin=:cores, max_threads=Threads.nthreads(), filename="weak-scaling.csv")
    pinthreads(pin)

    # warmup
    _picalc(1000)

    open(joinpath(@__DIR__, filename), "w") do file
        base = 1000000000
        println(file, "# threads, number of steps, elapsed time (seconds)")
        for nthreads in filter(<=(max_threads), nthreads_list)
            numsteps = nthreads * base
            # Time in seconds
            time = @elapsed _picalc(numsteps; nthreads)
            @show nthreads, numsteps, time
            println(file, nthreads, ",", numsteps, ",", time)
        end
    end
end

function strong_scaling(; pin=:cores, max_threads=Threads.nthreads(), filename="strong-scaling.csv")
    pinthreads(pin)

    # warmup
    _picalc(1000)

    open(joinpath(@__DIR__, filename), "w") do file
        numsteps = 1000000000
        println(file, "# threads, number of steps, elapsed time (seconds)")
        for nthreads in filter(<=(max_threads), nthreads_list)
            # Time in seconds
            time = @elapsed _picalc(numsteps; nthreads)
            @show nthreads, numsteps, time
            println(file, nthreads, ",", numsteps, ",", time)
        end
    end
end

function perf_profile(; pin=:cores, max_threads=Threads.nthreads(), filename="perf-profile.log")
    pinthreads(pin)

    insn = "(cpu-cycles, stalled-cycles-frontend, stalled-cycles-backend),(instructions, branch-misses),(cache-references, cache-misses),(task-clock, page-faults)"
    # warmup
    @pstats insn _picalc(1000)

    open(joinpath(@__DIR__, filename), "w") do file
        numsteps = 1000000000
        for nthreads in filter(<=(max_threads), nthreads_list)
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

# Adapted from
# https://github.com/JuliaCI/BenchmarkTools.jl/pull/94/files#diff-151c7e3dd2635b8bb88f9c9ea50586c7c0cd82139edf6c3029f579e538e8f7bd
# Do something like
#     N=80; t0=Measurement(); _picalc(N*1000000000; nthreads=N); t1=Measurement(); d = MeasurementDelta(t1, t0); (realtime=d.realtime, sched_ratio=d.cpuratio/N)
struct TimeSpec
    tv_sec  :: UInt64 # time_t
    tv_nsec :: UInt64
end

maketime(ts) = ts.tv_sec * 1e9 + ts.tv_nsec

# From bits/times.h on a Linux system
# Check if those are the same on BSD
const CLOCK_MONOTONIC          = Cint(1)
const CLOCK_PROCESS_CPUTIME_ID = Cint(2)


@inline function clock_gettime(cid)
    ts = Ref{TimeSpec}()
    ccall(:clock_gettime, Cint, (Cint, Ref{TimeSpec}), cid, ts)
    return ts[]
end

@inline function realtime()
    maketime(clock_gettime(CLOCK_MONOTONIC))
end

@inline function cputime()
    maketime(clock_gettime(CLOCK_PROCESS_CPUTIME_ID))
end

struct Measurement
    realtime::TimeSpec
    cputime::TimeSpec
    function Measurement()
        rtime = clock_gettime(CLOCK_MONOTONIC)
        ctime = clock_gettime(CLOCK_PROCESS_CPUTIME_ID)
        return new(rtime, ctime)
    end
end

struct MeasurementDelta
    realtime::Float64
    cpuratio::Float64
    function MeasurementDelta(t1::Measurement, t0::Measurement)
        rt0 = maketime(t0.realtime)
        ct0 = maketime(t0.cputime)
        rt1 = maketime(t1.realtime)
        ct1 = maketime(t1.cputime)
        realtime = rt1 - rt0
        cputime = ct1 - ct0
        return new(realtime, cputime/realtime)
    end
end
