#!/bin/bash

export OPENBLAS_NUM_THREADS=1
julia --threads=auto --project=. -L pi.jl -e '
# Runs with ":cores" pinning
sleep(2);
weak_scaling();
sleep(10);
strong_scaling();
sleep(10);
perf_profile();

# Runs with alternate pinning
pin = 0:2:191;
max_threads=96;
sleep(10);
weak_scaling(; pin, max_threads, filename="weak-scaling-pinned-alternated.csv");
sleep(10);
strong_scaling(; pin, max_threads, filename="strong-scaling-pinned-alternated.csv");
perf_profile(; pin, max_threads, filename="perf-profile-pinned-alternated.log")'
