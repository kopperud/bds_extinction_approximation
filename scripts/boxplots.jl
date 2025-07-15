using CSV
using DataFrames
using CairoMakie
using LaTeXStrings

df = CSV.read("output/munged.csv", DataFrame)


fig = Figure(size = (300, 300))

xt = [0, 1]
xtl = [L"\text{allow}", L"\text{disallow}"]

ax = Axis(
    fig[1,1],
    topspinevisible = false,
    rightspinevisible = false,
    xgridvisible = false,
    ygridvisible = false,
    xlabel = "",
    ylabel = L"\text{extinction rate }(\mu)",
    xticks = (xt, xtl),
    title = L"\text{a)}",
    titlealign = :left,
)

## 
# boxplot(categories, values, dodge = dodge, show_notch = true, color = dodge)
df1 = filter(row -> row[:rate_shifts] == "allow", df)
df2 = filter(row -> row[:rate_shifts] == "disallow", df)
n = size(df1)[1]

boxplot!(ax, [0 for _ in 1:n], df1[!,:mean_extinction]; show_notch = true)
boxplot!(ax, [1 for _ in 1:n], df2[!,:mean_extinction]; show_notch = true)

fig




