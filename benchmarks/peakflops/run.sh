#!/bin/bash

# Suggested by Martin Kroeker at
# https://x.com/KroekerMartin/status/1866148434924703755, it seems to get ~25%
# more flops than with the generic armv8 kernels.
export OPENBLAS_CORETYPE=NEOVERSEN1
julia --project=. peakflops.jl
