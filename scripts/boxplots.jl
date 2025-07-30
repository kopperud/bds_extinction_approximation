using CSV
using DataFrames
using CairoMakie
using LaTeXStrings
using Statistics

df = CSV.read("output/munged.csv", DataFrame)
df_branches = CSV.read("output/munged_branches.csv", DataFrame)


fig = Figure(size = (600, 300))

xt = [0, 1]
xtl = [L"\text{allow}", L"\text{disallow}"]

ax1 = Axis(
    fig[1,1],
    topspinevisible = false,
    rightspinevisible = false,
    xgridvisible = false,
    ygridvisible = false,
    xlabel = "",
    ylabel = L"\text{speciation rate }(\lambda)",
    xticks = (xt, xtl),
    title = L"\text{a)}",
    titlealign = :left,
)


ax2 = Axis(
    fig[1,2],
    topspinevisible = false,
    rightspinevisible = false,
    xgridvisible = false,
    ygridvisible = false,
    xlabel = "",
    ylabel = L"\text{extinction rate }(\mu)",
    xticks = (xt, xtl),
    title = L"\text{b)}",
    titlealign = :left,
)

ax3 = Axis(
    fig[1,3],
    topspinevisible = false,
    rightspinevisible = false,
    xgridvisible = false,
    ygridvisible = false,
    xlabel = "",
    ylabel = L"\text{netdiv rate }(\lambda - \mu)",
    xticks = (xt, xtl),
    title = L"\text{c)}",
    titlealign = :left,
)

## 
# boxplot(categories, values, dodge = dodge, show_notch = true, color = dodge)
df1 = filter(row -> row[:rate_shifts] == "allow", df)
df2 = filter(row -> row[:rate_shifts] == "disallow", df)

delta_extinction = df2.mean_extinction .- df1.mean_extinction
df2[delta_extinction .> 0.05,:]
#sort!(df2, :delta_extinction)

n = size(df1)[1]

boxplot!(ax1, [0 for _ in 1:n], df1[!,:mean_speciation]; show_notch = true)
boxplot!(ax1, [1 for _ in 1:n], df2[!,:mean_speciation]; show_notch = true)


boxplot!(ax2, [0 for _ in 1:n], df1[!,:mean_extinction]; show_notch = true)
boxplot!(ax2, [1 for _ in 1:n], df2[!,:mean_extinction]; show_notch = true)


boxplot!(ax3, [0 for _ in 1:n], df1[!,:mean_netdiv]; show_notch = true)
boxplot!(ax3, [1 for _ in 1:n], df2[!,:mean_netdiv]; show_notch = true)

fig
save("figures/phylogeny_rates.pdf", fig)


## plot deltas instead
fig2 = Figure(size = (600, 300))

xt = [0, 1, 2]
xtl = [L"\text{speciation}", L"\text{extinction}", L"\text{netdiv}"]

ax = Axis(
    fig2[1,1],
    topspinevisible = false,
    rightspinevisible = false,
    xgridvisible = false,
    ygridvisible = false,
    xlabel = "",
    ylabel = L"\Delta \text{rate}=x_\text{disallow} - x_\text{allow}",
    xticks = (xt, xtl),
    title = L"\text{a)}",
    titlealign = :left,
)

y1 = df2[!,:mean_speciation] .- df1[!,:mean_speciation]
y2 = df2[!,:mean_extinction] .- df1[!,:mean_extinction]
y3 = df2[!,:mean_netdiv] .- df1[!,:mean_netdiv]

boxplot!(ax, [0 for _ in 1:n], y1; show_notch = false)
boxplot!(ax, [1 for _ in 1:n], y2; show_notch = false)
boxplot!(ax, [2 for _ in 1:n], y3; show_notch = false)

lines!(ax, [-1.0, 3.0], [0.0, 0.0], linestyle = :dash, color = :red, label = L"\Delta \text{rate} = 0")

axislegend(ax)

xlims!(ax, (-0.5, 2.5))

fig2
save("figures/phylogeny_rates_delta.pdf", fig2)

##### 
# delta histogram

df1 = filter(row -> row[:rate_shifts] == "allow", df_branches)
df2 = filter(row -> row[:rate_shifts] == "disallow", df_branches)

y1 = df2[!,:mean_lambda] .- df1[!,:mean_lambda]
y2 = df2[!,:mean_mu] .- df1[!,:mean_mu]
y3 = df2[!,:mean_netdiv] .- df1[!,:mean_netdiv]

fig3 = Figure(size = (400, 300))
ax = Axis(
    fig3[1, 1],
    xgridvisible = false,
    ygridvisible = false,
    topspinevisible = false,
    rightspinevisible = false,
    yticks = ([1.5, 2.5, 3.5], [L"\text{speciation}", L"\text{extinction}", L"\text{netdiv}"]),
    xlabel = L"\Delta = \text{branch rate (disallowed)} - \text{branch rate (allowed)}",
    yticklabelrotation = π/4.0,
)
for (i, y) in enumerate([y1, y2, y3])
     hist!(ax, y, scale_to=0.9, offset=i, direction=:y, bins = 500)
end
lines!(ax, [0.0, 0.0], [1.0, 4.0], linestyle = :dash, color = (:red, 0.4), label = "Δ = 0")
axislegend(ax)
xlims!(ax, (-0.05, 0.05))
fig3


save("figures/branch_rates_delta.pdf", fig3)


Δλ = Statistics.mean(y1)
Δμ = Statistics.mean(y2)
Δr = Statistics.mean(y3)


Δλ_se = sqrt(Statistics.var(y1)) / sqrt(length(y1))
Δμ_se = sqrt(Statistics.var(y2)) / sqrt(length(y2))
Δr_se = sqrt(Statistics.var(y3)) / sqrt(length(y3))

println("Δλ = $Δλ ± $Δλ_se")
println("Δμ = $Δμ ± $Δμ_se")
println("Δr = $Δr ± $Δr_se")

