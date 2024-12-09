#!/bin/bash

# Fix number of threads
export OMP_NUM_THREADS=1

# ARMPL currently requires you to set `LD_LIBRARY_PATH` to load the libraries.
export LD_LIBRARY_PATH="${HOME}/tmp/arm-performance-libraries_24.10_rpm/armpl-24.10/armpl_24.10_gcc/lib"
julia --project=. armpl-axpy.jl
