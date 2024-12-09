#!/bin/bash

julia --threads=192 -L pi.jl -e 'weak_scaling(); strong_scaling()'
