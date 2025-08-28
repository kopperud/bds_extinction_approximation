using CSV
using DataFrames
using LaTeXStrings
using Makie
using CairoMakie
using MakieExtra


colors = Makie.wong_colors()

fig = Figure(size = (700, 450))

Label(fig[1,1:2], L"\text{a) constant extinction}")
Label(fig[1,3:4], L"\text{b) variable extinction}")


Label(fig[2,1], L"\text{fixed }\hat{\lambda},\hat{\mu}")
Label(fig[2,2], L"\text{estimated }\hat{\lambda},\hat{\mu}")

Label(fig[2,3], L"\text{fixed }\hat{\lambda},\hat{\mu}")
Label(fig[2,4], L"\text{estimated }\hat{\lambda},\hat{\mu}")
#Label(fig[1:2,0], L"\text{rate shifts not allowed}", rotation = π/2)

Label(fig[6,1:4], L"\text{allowing or disallowing rate shifts on extinct lineages}")

fig

axs = Matrix{Axis}(undef, 3,4)

ylabels = [
        L"\text{speciation}",
        L"\text{extinction}",
        L"\text{shift rate}",
]

xt = [2.5, 6.5]
xtl = [L"\text{allow}", L"\text{disallow}"]

for row in 1:3
    for col in 1:4
        ax = Axis(fig[2+row, col],
            topspinevisible = false,
            rightspinevisible = false,
            xgridvisible = false,
            ygridvisible = false,
            ylabel  = ylabels[row],
            xticks = (xt, xtl),
            yticklabelsize = 11,
            xticklabelsize = 11,
        )
        if col > 1
            hideydecorations!(ax, ticks = false)
        end

        if row < 3
            hidexdecorations!(ax, ticks = false)
        end

        axs[row,col] = ax
    end
end

rand(40)

for row in 1:3
    for col in 1:4
        for i in 1:4
            violin!(axs[row, col], [i for _ in 1:40], rand(40), color = (colors[i], 0.7), show_median = true)
            violin!(axs[row, col], [4+i for _ in 1:40], 0.5 .+ rand(40), color = (colors[i], 0.7), show_median = true)
        end
    end
end

fig

for col in 1:4
    colsize!(fig.layout, col, Relative(0.25))
end

rowsize!(fig.layout, 1, Relative(0.04))
rowsize!(fig.layout, 2, Relative(0.04))
rowsize!(fig.layout, 6, Relative(0.04))
for row in 3:5
    rowsize!(fig.layout, row, Relative(0.29333))
end

colgap!(fig.layout, 10)
rowgap!(fig.layout, 10)

linkxaxes!(axs...)

for row in 1:3
    linkyaxes!(axs[row,:]...)
end  

fig

save("figures/revbayes_mockup.pdf", fig)

