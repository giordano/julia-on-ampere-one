using Plots, DelimitedFiles

function plot_weak_scaling(input, title, yticks, output)
    weak_scaling = readdlm(joinpath(@__DIR__, input), ',', Float64; skipstart=1)

    nthreads = Int.(weak_scaling[:, 1])

    p = plot(nthreads, weak_scaling[1, 3] ./ weak_scaling[:, 3];
             xticks=(nthreads, string.(nthreads)),
             xscale=:log2,
             xlabel="Number of threads",
             yticks,
             ylabel="Parallel efficiency",
             marker=:circle,
             markersize=3,
             label="",
             title,
             )
    savefig(output)
end

function plot_strong_scaling(input, title, yticks, output)
    strong_scaling = readdlm(joinpath(@__DIR__, input), ',', Float64; skipstart=1)

    nthreads = Int.(strong_scaling[:, 1])

    p = plot(nthreads, strong_scaling[1, 3] ./ strong_scaling[:, 3] ./ nthreads;
             xticks=(nthreads, string.(nthreads)),
             xscale=:log2,
             xlabel="Number of threads",
             yticks,
             ylabel="Parallel efficiency",
             marker=:circle,
             markersize=3,
             label="",
             title,
             )
    savefig(output)
end

plot_weak_scaling("weak-scaling.csv", "Weak scaling of pi example (pin: cores)", 0.6:0.05:1.1, "weak-scaling.pdf")
plot_strong_scaling("strong-scaling.csv", "Strong scaling of pi example (pin: cores)", 0.4:0.05:1.1, "strong-scaling.pdf")
plot_weak_scaling("weak-scaling-pinned-alternated.csv", "Weak scaling of pi example (pin: 0:2:191)", 0.98:0.001:1.1, "weak-scaling-pinned-alternated.pdf")
plot_strong_scaling("strong-scaling-pinned-alternated.csv", "Strong scaling of pi example (pin: 0:2:191)", 0.98:0.002:1.1, "strong-scaling-pinned-alternated.pdf")
