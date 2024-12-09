#!/bin/bash

julia --startup-file=no --project=. --threads=192 bench.jl | tee output.txt
