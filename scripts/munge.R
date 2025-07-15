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

dfs <- list()

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
}

d <- bind_rows(dfs)

write.csv(d, "output/munged.csv")
