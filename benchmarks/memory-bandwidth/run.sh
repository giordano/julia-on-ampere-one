#!/bin/bash

julia --startup-file=no --project=. --threads=auto bench.jl | tee output.txt
