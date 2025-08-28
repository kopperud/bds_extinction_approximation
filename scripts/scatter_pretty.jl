using CSV
using DataFrames
using LaTeXStrings
using Makie
using CairoMakie
using MakieExtra


function foobar(value)

    if value <= 0.0
        txt = "NaN"
        txt = "0"
    else
        scale = round(log10(value); digits = 0)

        c = 10^(scale)

        value = round(value / c; digits = 1)

        scale_int = Int64(scale)

        if scale_int == 0
            txt = rich("$value")
        else
            value_int = Int64(round(value; digits = 0))
            txt = rich("$(value_int)x10", superscript("$scale_int"))
        end
    end

    return(txt)
end

function foobar2(value)
    if value <= 0.0
        txt = "NaN"
        txt = "0"
    else
        if value >= 0.001
            txt = "$value"
        else
            scale = round(log10(value); digits = 0)
            c = 10^(scale)

            value = round(value / c; digits = 1)
            scale_int = Int64(scale)

            if scale_int == 0
                txt = rich("$value")
            else
                value_int = Int64(round(value; digits = 0))
                txt = rich("$(value_int)e$scale_int")
            end
        end
    end

    return(txt)
end

#foobar2(0.00001)





fig3 = Figure()
v = foobar(0.031)
ax = Axis(
    fig3[1,1], 
    ylabel = v, 
    yscale = log10,
    #xtickformat = x -> [foobar(xi) for xi in x], 
    yminorticksvisible = true,
    yminorticks = BaseMulTicks(2:9)
)
fig3




df = CSV.read("output/munged.csv", DataFrame)

fig = Figure(size = (850, 350))

titles = [
    L"\text{a) speciation rate}",
    L"\text{b) extinction rate}",
    L"\text{c) netdiv rate}",
    L"\text{d) shift rate}",
    L"\text{e) supported shifts}",
]

ticks = [
    ([0.00003, 0.0003, 0.003, 0.03, 0.3, 3.0], ["0.00003", "0.0003", "0.003", "0.03", "0.3", "3.0"])
]



axs = []
for col in 1:5
    println(col)
    if col < 5
        xscale = log10
        yscale = log10
        #yticks = ticks[1]
        #xticks = ticks[1]
        xticks = BaseMulTicks([1, 10])
        yticks = BaseMulTicks([1, 10])
        ytickformat = y -> [foobar2(yi) for yi in y]
        xtickformat = x -> [foobar2(xi) for xi in x]
    else
        xscale = identity
        yscale = identity
        xticks = [0, 100, 200, 300, 400]
        yticks = [0, 100, 200, 300, 400]
        ytickformat = "{:.0f}" 
        xtickformat = "{:.0f}" 
    end

        if col == 1 || col == 3 
        yminorticks = BaseMulTicks(2:9)
        xminorticks = BaseMulTicks(2:9)
        yminorticksvisible = true
        xminorticksvisible = true
    else
        yminorticks = nothing
        xminorticks = nothing
        yminorticksvisible = false
        xminorticksvisible = false
    end

    ax = Axis(fig[1,col],
        topspinevisible = false,
        rightspinevisible = false,
        xgridvisible = false,
        ygridvisible = false,
        xscale = xscale, 
        yscale = yscale,
        ytickformat = ytickformat,
        xtickformat = xtickformat,
        xticks = xticks,
        yticks = yticks,
        yminorticks = yminorticks,
        yminorticksvisible = yminorticksvisible,
        xminorticks = xminorticks,
        xminorticksvisible = xminorticksvisible,
        xlabel = "",
        ylabel = "", 
        yticklabelsize = 11,
        xticklabelsize = 11,
        title = titles[col],
    )

    #if col > 1
        #hideydecorations!(ticks = false)
    #end
    
    hidexdecorations!(ticks = false)
    push!(axs, ax)
end

for col in 1:5
    if col < 5
        xscale = log10
        yscale = log10
        xticks = BaseMulTicks([1, 10])
        yticks = BaseMulTicks([1, 10])
        #yticks = ticks[1]
        #xticks = ticks[1]
        ytickformat = y -> [foobar2(yi) for yi in y]
        xtickformat = x -> [foobar2(xi) for xi in x]
    else
        xscale = identity
        yscale = identity
        xticks = [0, 100, 200, 300, 400]
        yticks = [0, 100, 200, 300, 400]
        ytickformat = "{:.0f}" 
        xtickformat = "{:.0f}" 
    end

    if col == 1 || col == 3 
        yminorticks = BaseMulTicks(2:9)
        xminorticks = BaseMulTicks(2:9)
        yminorticksvisible = true
        xminorticksvisible = true
    else
        yminorticks = nothing
        xminorticks = nothing
        yminorticksvisible = false
        xminorticksvisible = false
    end
 
    ax = Axis(fig[2,col],
        topspinevisible = false,
        rightspinevisible = false,
        xgridvisible = false,
        ygridvisible = false,
        xscale = xscale, 
        yscale = yscale,
        #xtickformat = EngTicks(),
        #ytickformat = EngTicks(),
        ytickformat = ytickformat,
        xtickformat = xtickformat,
        yminorticks = yminorticks,
        yminorticksvisible = yminorticksvisible,
        xminorticks = yminorticks,
        xminorticksvisible = yminorticksvisible,
        xticklabelrotation = π/2,
        xticks = xticks,
        yticks = xticks,
        xlabel = "",
        ylabel = "", 
        yticklabelsize = 11,
        xticklabelsize = 11,
    )    
    #if col > 1
        #hideydecorations!(ticks = false)
    #end

    push!(axs, ax)
end

Label(fig[1:2,0], L"\text{rate shifts not allowed}", rotation = π/2)
Label(fig[3,1:5], L"\text{rate shifts allowed on extinct lineages}")


Label(fig[1,6], L"\text{constant extinction}", rotation = π/2)
Label(fig[2,6], L"\text{varying extinction}", rotation = π/2)


for i in 1:5
    linkaxes!([axs[i], axs[i+5]])
end

for (i, var) in enumerate([:mean_speciation, :mean_extinction, :mean_netdiv, :eta, :no_signif_shifts])
    dfx = filter(x -> x[:extinction_assumption] == "constant", df)

    df_allow = filter(x -> x[:rate_shifts] == "allow", dfx)
    df_disallow = filter(x -> x[:rate_shifts] == "disallow", dfx)

    x = df_allow[!,var]
    y = df_disallow[!,var]
    x0, x1 = extrema(x)
    lines!(axs[i], [x0, x1], [x0, x1], linestyle = :dash, color = :black)
    scatter!(axs[i], x, y, strokecolor = :black, strokewidth = 1, color = :white)
end


for (i, var) in enumerate([:mean_speciation, :mean_extinction, :mean_netdiv, :eta, :no_signif_shifts])
    dfx = filter(x -> x[:extinction_assumption] == "variable", df)

    df_allow = filter(x -> x[:rate_shifts] == "allow", dfx)
    df_disallow = filter(x -> x[:rate_shifts] == "disallow", dfx)

    x = df_allow[!,var]
    y = df_disallow[!,var]
    x0, x1 = extrema(x)
    lines!(axs[i+5], [x0, x1], [x0, x1], linestyle = :dash, color = :black)
    scatter!(axs[i+5], x, y, strokecolor = :black, strokewidth = 1, color = :lightgray)
end

rowgap!(fig.layout, 10.0)
colgap!(fig.layout, 10.0)

fig

save("figures/scatter_pretty.pdf", fig)


fig2 = Figure()

dfx = filter(x -> x[:extinction_assumption] == "variable", df)
df_allow = filter(x -> x[:rate_shifts] == "allow", dfx)
df_disallow = filter(x -> x[:rate_shifts] == "disallow", dfx)

xt = [0.0, 0.25, 0.50, 0.75, 1.0]
xtl = ["0.0", "0.25", "0.50", "0.75", "1.0"]
ax = Axis(fig2[1,1], 
        topspinevisible = false,
        rightspinevisible = false,
        xgridvisible = false,
        ygridvisible = false,
        xlabel = L"\text{sampling fraction}",
        ylabel = L"\lambda_\text{not allowed} - \lambda_\text{allowed}",
        xticks = (xt, xtl),
)

x = df_allow[!,:sampling_fraction]
y = df_disallow[!,:mean_speciation] .- df_allow[!,:mean_speciation]
#y = df_disallow[!,:eta] .- df_allow[!,:eta]
#y = df_disallow[!,:mean_netdiv] .- df_allow[!,:mean_netdiv]

scatter!(ax, x, y)
fig2

argmax(y)

df_allow[48,:]

hist(y, bins = 50)

Statistics.median(y)
sum(y) / 100



z1 = df_disallow[!,:mean_extinction] ./ df_allow[!,:mean_extinction]
z = log10.(z1)
hist(z1)



fig4 = Figure(size = (850, 350))
xt = log10.([0.80, 1.0, 1.25, 1.50, 1.8])
xtl = ["$(10^v)" for v in xt]

axs = []

for col in 1:5
    if col < 5
        xtickformat = x -> ["$(round(10^xi; digits = 2))" for xi in x]
    else
        xtickformat = x -> ["$xi" for xi in x]
    end

    ax = Axis(
        fig4[1,col],
        xtickformat = xtickformat,
        xticklabelrotation = π/2,
        xgridvisible = false,
        ygridvisible = false,
        topspinevisible = false,
        rightspinevisible = false,
        title = titles[col],
        yticklabelsize = 11,
        xticklabelsize = 11,
    )

    if col > 1
        hideydecorations!(ticks = false)
    end

    hidexdecorations!(ax, ticks = false)
    push!(axs, ax)
end

for col in 1:5
    if col == 4
        xtickformat = x -> ["$(round(10^xi; digits = 4))" for xi in x]
    elseif col < 5
        xtickformat = x -> ["$(round(10^xi; digits = 2))" for xi in x]
        #xtickformat = x -> [foobar2(xi) for xi in x]
    else
        xtickformat = x -> ["$xi" for xi in x]
    end
    
    ax = Axis(
        fig4[2,col],
        xtickformat = xtickformat,
        xticklabelrotation = π/2,
        xgridvisible = false,
        ygridvisible = false,
        topspinevisible = false,
        rightspinevisible = false,
        yticklabelsize = 11,
        xticklabelsize = 11,
    )
    
    if col > 1
        hideydecorations!(ticks = false)
    end

    push!(axs, ax)
end

nbins = [6, [-0.007, 0.007], 16, 10, 16]

xlims = zeros(5,2)
for (i, var) in enumerate([:mean_speciation, :mean_extinction, :mean_netdiv, :eta])
    dfx = filter(x -> x[:extinction_assumption] == "constant", df)

    df_allow = filter(x -> x[:rate_shifts] == "allow", dfx)
    df_disallow = filter(x -> x[:rate_shifts] == "disallow", dfx)

    r = df_disallow[!,var] ./ df_allow[!,var]
    x = log10.(r)
    
    hist!(axs[i], x, bins = nbins[i], color = :white, strokecolor = :black, strokewidth = 1)
    xlims[i,:] .= extrema(x)
end

nbins = [20, 20, 10, 14, 20]

for (i, var) in enumerate([:mean_speciation, :mean_extinction, :mean_netdiv, :eta])
    dfx = filter(x -> x[:extinction_assumption] == "variable", df)

    df_allow = filter(x -> x[:rate_shifts] == "allow", dfx)
    df_disallow = filter(x -> x[:rate_shifts] == "disallow", dfx)

    r = df_disallow[!,var] ./ df_allow[!,var]
    x = log10.(r)
    
    hist!(axs[i+5], x, bins = nbins[i], color = :lightgray, strokecolor = :black, strokewidth = 1)
    xlims[i,1] = minimum([xlims[i,1], minimum(x)])
    xlims[i,2] = maximum([xlims[i,2], maximum(x)])
end

for (idx, analysis, color) in zip([5,10], ["constant", "variable"], [:white, :lightgray])
    dfx = filter(x -> x[:extinction_assumption] == "variable", df)

    df_allow = filter(x -> x[:rate_shifts] == "allow", dfx)
    df_disallow = filter(x -> x[:rate_shifts] == "disallow", dfx)

    x = df_disallow[!,:no_signif_shifts] .- df_allow[!,:no_signif_shifts]
    
    hist!(axs[idx], x, bins = 20, color = color, strokecolor = :black, strokewidth = 1)
    xlims[5,1] = minimum([xlims[5,1], minimum(x)])
    xlims[5,2] = maximum([xlims[5,2], maximum(x)])
end

for idx in 1:5
    lines!(axs[idx], [0.0, 0.0], [0.0, 100.0], color = :black, linestyle = :dash)
    lines!(axs[idx+5], [0.0, 0.0], [0.0, 83.0], color = :black, linestyle = :dash)
end

xl = [maximum(abs.(xlims[i,:])) for i in 1:5] .* 1.1

for idx in 1:5
    lims = [-xl[idx], xl[idx]]
    xlims!(axs[idx], lims...)
    xlims!(axs[idx+5], lims...)
end

#for i in 1:5
    #linkxaxes!([axs[i], axs[i+5]])
#end

linkyaxes!(axs[1:5]...)
linkyaxes!(axs[6:10]...)

Label(fig4[3,1:4], L"\text{relative change in estimate when disallowing rate shifts on extinct lineages}")
Label(fig4[3,5], L"\text{absolute change}")
Label(fig4[1:2,0], L"\text{number of phylogenies}", rotation = π/2.0)

Label(fig4[1,6], L"\text{constant extinction}", rotation = π/2.0)
Label(fig4[2,6], L"\text{variable extinction}", rotation = π/2.0)

rowgap!(fig4.layout, 10.0)
colgap!(fig4.layout, 10.0)

for i in 1:5
    colsize!(fig4.layout, i, Relative(0.20))
end

fig4

save("figures/histogram_pretty.pdf", fig4)


## calculate some summaries and print
function baz(idx, df_disallow, df_allow)
    rel_sp = df_disallow[idx,:mean_speciation] / df_allow[idx,:mean_speciation]
    rel_ex = df_disallow[idx,:mean_extinction] / df_allow[idx,:mean_extinction]
    rel_netdiv = df_disallow[idx,:mean_netdiv] / df_allow[idx,:mean_netdiv]
    rel_eta = df_disallow[idx,:eta] / df_allow[idx,:eta]

    abs_nstar = df_disallow[idx,:no_signif_shifts] .- df_allow[idx,:no_signif_shifts]

    println("speciation changed by factor of $rel_sp")
    println("extinction changed by factor of $rel_ex")
    println("netdiv changed by factor of $rel_netdiv")
    println("eta changed by factor of $rel_eta")
    println("Nstar changed by $abs_nstar")
end


dfx = filter(x -> x[:extinction_assumption] == "variable", df)

df_allow = filter(x -> x[:rate_shifts] == "allow", dfx)
df_disallow = filter(x -> x[:rate_shifts] == "disallow", dfx)

ratios = df_disallow[!,:mean_extinction] ./ df_allow[!,:mean_extinction]

for (i, r) in enumerate(ratios)
    if r > 1.5
        println(i)
    end
end


baz(48, df_disallow, df_allow)
baz(65, df_disallow, df_allow) ## Galliformes 
baz(98, df_disallow, df_allow)

baz(55, df_disallow, df_allow)

for (i, name) in enumerate(df_disallow[!,:name])
    println("$i:    $name")
end


