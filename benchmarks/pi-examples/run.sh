#!/bin/bash

julia --threads=auto --project=. -L pi.jl -e 'weak_scaling(); strong_scaling()'
