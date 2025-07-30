library(tibble)
library(dplyr)
library(tidyr)

make_summary <- function(x, name){
    d <- as_tibble(x$td)

    df1 <- tibble(
            "eta" = x$model[["eta"]],
            "no_signif_shifts" = sum(d$shift_bf > 10),
            "mean_extinction" = sum(d$mean_mu * d$branch.length) / sum(d$branch.length),
            "mean_speciation" = sum(d$mean_lambda * d$branch.length) / sum(d$branch.length),
            "mean_netdiv" = sum(d$mean_netdiv * d$branch.length) / sum(d$branch.length),
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

    df1 <- make_summary(analysis1, bn)
    df1$rate_shifts <- "allow"
    df2 <- make_summary(analysis2, bn)
    df2$rate_shifts <- "disallow"
    
    dfs[[i]] <- bind_rows(df1, df2)

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


