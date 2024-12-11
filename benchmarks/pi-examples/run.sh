#!/bin/bash

export OPENBLAS_NUM_THREADS=1
julia --threads=auto --project=. -L pi.jl -e 'weak_scaling(); strong_scaling(); perf_profile()'
