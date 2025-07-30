using CairoMakie

## RPesto
include("/home/bkopper/times_rpesto_allow.txt")
include("/home/bkopper/probs_rpesto_allow.txt")

probs_rpesto_allow = hcat(probs_rpesto_allow...)

include("/home/bkopper/times_rpesto_disallow.txt")
include("/home/bkopper/probs_rpesto_disallow.txt")

probs_rpesto_disallow = hcat(probs_rpesto_disallow...)

## RevBayes
include("/home/bkopper/times_revbayes_allow.txt")
include("/home/bkopper/probs_revbayes_allow.txt")

probs_revbayes_allow = hcat(probs_revbayes_allow...)

include("/home/bkopper/times_revbayes_disallow.txt")
include("/home/bkopper/probs_revbayes_disallow.txt")

probs_revbayes_disallow = hcat(probs_revbayes_disallow...)


## set up the plot skeleton

titles = ["allow", "disallow", "allow", "disallow"]

fig = Figure(size = (1200, 6000))

axs = Array{Axis}(undef, 25, 4)

for row in 1:25
    if row == 25
        xlabel = "time"
    else
        xlabel = ""
    end

    for col in 1:2
        if row == 1
            title = titles[col]
        else
            title = "" 
        end

        ax = Axis(fig[row,col],
                  topspinevisible = false,
                  rightspinevisible = false,
                  xgridvisible = false,
                  ygridvisible = false,
                  title = title,
                  xlabel = xlabel,
                  ylabel = "extinction probability ($row)",
                  xreversed = true,
                  )
        axs[row,col] = ax
    end

    for col in 3:4
        if row == 1
            title = titles[col]
        else
            title = "" 
        end

        ax = Axis(fig[row,col],
                  topspinevisible = false,
                  rightspinevisible = false,
                  xgridvisible = false,
                  ygridvisible = false,
                  title = title,
                  xlabel = xlabel,
                  ylabel = "branch probability ($row)",
                  xreversed = true,
                  )
        axs[row,col] = ax
    end
end

linkaxes!(axs...)

k = 25

## do plots
for row in 1:25
    lines!(axs[row,1], times_rpesto_allow, probs_rpesto_allow[row, :], color = "black")
    lines!(axs[row,2], times_rpesto_disallow, probs_rpesto_disallow[row, :], color = "black")

    lines!(axs[row,3], times_rpesto_allow, probs_rpesto_allow[row+k, :], color = "black")
    lines!(axs[row,4], times_rpesto_disallow, probs_rpesto_disallow[row+k, :], color = "black")

    plot!(axs[row,1], times_revbayes_allow, probs_revbayes_allow[row, :], color = "red")
    plot!(axs[row,2], times_revbayes_disallow, probs_revbayes_disallow[row, :], color = "red")

    plot!(axs[row,3], times_revbayes_allow, probs_revbayes_allow[row+k, :], color = "cyan")
    plot!(axs[row,4], times_revbayes_disallow, probs_revbayes_disallow[row+k, :], color = "cyan")
end


save("figures/rb_rpesto_compare_branch_probabilities.pdf", fig)

