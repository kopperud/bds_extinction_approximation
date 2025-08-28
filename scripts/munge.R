library(tibble)
library(dplyr)
library(tidyr)
library(ape)

weighted_mean <- function(x, w){
    n <- length(x)
    res <- sum(x * w) / sum(w)
    return(res)
}

weighted_geometric_mean <- function(x, w){
    n <- length(x)
    res <- exp(sum(w * log(x)) / sum(w))
    return(res)
}

make_summary <- function(x, name){
    d <- as_tibble(x$td)

    df1 <- tibble(
            "eta" = x$model[["eta"]],
            "no_signif_shifts" = sum(d$shift_bf > 10),
            "mean_extinction" = sum(d$mean_mu * d$branch.length) / sum(d$branch.length),
            "mean_speciation" = sum(d$mean_lambda * d$branch.length) / sum(d$branch.length),
            "mean_netdiv" = sum(d$mean_netdiv * d$branch.length) / sum(d$branch.length),
            "geo_mean_extinction" = weighted_geometric_mean(d$mean_mu, d$branch.length),
            "geo_mean_speciation" = weighted_geometric_mean(d$mean_lambda, d$branch.length),
            #"geo_mean_netdiv" = weighted_geometric_mean(d$mean_netdiv, d$branch.length),
            "height" = max(node.depth.edgelength(x$td@phylo)),
            "ntip" = length(x$td@phylo$tip.label),
            "name" = name
                 )
    return (df1)
}

make_summary2 <- function(x, name){
    d <- as_tibble(x$td)
    d$name <- name

    return(d)
}

dfs <- list()
dfs2 <- list()

fnames <- Sys.glob("output/*.RData")

for (i in 1:length(fnames)){
    bn <- gsub("\\.RData", "", fnames[[i]])
    bn <- gsub("output/", "", bn)

    load(fnames[[i]]) ## loads the `analyses` variable

    analysis1 <- analyses[[1]]
    analysis2 <- analyses[[2]]
    analysis3 <- analyses[[3]]
    analysis4 <- analyses[[4]]

    df1 <- make_summary(analysis1, bn)
    df1$rate_shifts <- "allow"
    df1$extinction_assumption <- "variable"

    df2 <- make_summary(analysis2, bn)
    df2$rate_shifts <- "disallow"
    df2$extinction_assumption <- "variable"

    df3 <- make_summary(analysis3, bn)
    df3$rate_shifts <- "allow"
    df3$extinction_assumption <- "constant"

    df4 <- make_summary(analysis4, bn)
    df4$rate_shifts <- "disallow"
    df4$extinction_assumption <- "constant"
    
    dfs[[i]] <- bind_rows(df1, df2, df3, df4)
    dfs[[i]]$sampling_fraction <- analyses[[5]]

    df1_branches <- make_summary2(analysis1, bn)
    df1_branches$rate_shifts <- "allow"
    df2_branches <- make_summary2(analysis2, bn)
    df2_branches$rate_shifts <- "disallow"

    dfs2[[i]] <- bind_rows(df1_branches, df2_branches) 
}

d1 <- bind_rows(dfs)
write.csv(d1, "output/munged.csv")


d2 <- bind_rows(dfs2)
write.csv(d2, "output/munged_branches.csv")


