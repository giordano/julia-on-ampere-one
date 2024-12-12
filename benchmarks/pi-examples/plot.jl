using Plots, DelimitedFiles

function plot_weak_scaling()
    weak_scaling = readdlm(joinpath(@__DIR__, "weak-scaling.csv"), ',', Float64; skipstart=1)
    weak_scaling_alternated = readdlm(joinpath(@__DIR__, "weak-scaling-pinned-alternated.csv"), ',', Float64; skipstart=1)

    nthreads = Int.(weak_scaling[:, 1])
    p = plot(nthreads, weak_scaling[1, 3] ./ weak_scaling[:, 3];
             xticks=(nthreads, string.(nthreads)),
             xscale=:log2,
             xlabel="Number of threads",
             yticks=0.6:0.05:1.1,
             ylabel="Parallel efficiency",
             marker=:circle,
             markersize=3,
             label="pin: cores",
             legend=:right,
             title="Weak scaling of pi example",
             )

    nthreads_alternated = Int.(weak_scaling_alternated[:, 1])
    plot!(p, nthreads_alternated, weak_scaling_alternated[1, 3] ./ weak_scaling_alternated[:, 3];
          marker=:circle,
          markersize=3,
          label="pin: 0:2:191",
          )

    savefig(p, "weak-scaling.pdf")
end

function plot_strong_scaling()
    strong_scaling = readdlm(joinpath(@__DIR__, "strong-scaling.csv"), ',', Float64; skipstart=1)
    strong_scaling_alternated = readdlm(joinpath(@__DIR__, "strong-scaling-pinned-alternated.csv"), ',', Float64; skipstart=1)

    nthreads = Int.(strong_scaling[:, 1])
    p = plot(nthreads, strong_scaling[1, 3] ./ strong_scaling[:, 3] ./ nthreads;
             xticks=(nthreads, string.(nthreads)),
             xscale=:log2,
             xlabel="Number of threads",
             yticks=0.4:0.05:1.1,
             ylabel="Parallel efficiency",
             marker=:circle,
             markersize=3,
             label="pin: cores",
             legend=:right,
             title="Strong scaling of pi example",
             )

    nthreads_alternated = Int.(strong_scaling_alternated[:, 1])
    plot!(p, nthreads_alternated, strong_scaling_alternated[1, 3] ./ strong_scaling_alternated[:, 3] ./ nthreads_alternated;
          marker=:circle,
          markersize=3,
          label="pin: 0:2:191",
          )

    savefig(p, "strong-scaling.pdf")
end

plot_weak_scaling()
plot_strong_scaling()
