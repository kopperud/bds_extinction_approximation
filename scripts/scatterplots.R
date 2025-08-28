library(ggplot2)
library(tibble)
library(tidytree)
library(dplyr)
library(tidyr)
library(patchwork)
library(ape)
library(ggrepel)

make_summary <- function(x, name){
    d <- as_tibble(x$td)

    df1 <- tibble(
            "eta" = x$model[["eta"]],
            "no_signif_shifts" = sum(d$shift_bf > 10),
            "mean_extinction" = sum(d$mean_mu * d$branch.length) / sum(d$branch.length),
            "mean_speciation" = sum(d$mean_lambda * d$branch.length) / sum(d$branch.length),
            "mean_netdiv" = sum(d$mean_netdiv * d$branch.length) / sum(d$branch.length),
            "name" = name,
            "height" = max(node.depth.edgelength(x$td@phylo)),
            "ntip" = length(x$td@phylo$tip.label),
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

#write.csv(d, "

dflambda <- d |>
    select(mean_speciation, rate_shifts, name) |>
    pivot_wider(names_from = rate_shifts, values_from = mean_speciation) 

dfmu <- d |>
    select(mean_extinction, rate_shifts, name) |>
    pivot_wider(names_from = rate_shifts, values_from = mean_extinction) |>
    mutate(delta = disallow - allow) |>
    arrange(desc(delta))

dfnetdiv <- d |>
    select(mean_netdiv, rate_shifts, name) |>
    pivot_wider(names_from = rate_shifts, values_from = mean_netdiv) 

dfeta <- d |>
    select(eta, rate_shifts, name) |>
    pivot_wider(names_from = rate_shifts, values_from = eta) 

dfNstar <- d |>
    select(no_signif_shifts, rate_shifts, name) |>
    pivot_wider(names_from = rate_shifts, values_from = no_signif_shifts) 

p1 <- dflambda |>
    ggplot(aes(x = allow, y = disallow, color = name)) +
    geom_point() +
    geom_abline(slope = 1, intercept = 0, linetype = 2) +
    labs(x = "rate shifts allowed on extinct lineages", y = "rate shifts not allowed on extinct lineages") +
    ggtitle("mean speciation rate") +
    theme_classic() 

p2 <- dfmu |> 
    ggplot(aes(x = allow, y = disallow, color = name)) +
    geom_point() +
    geom_abline(slope = 1, intercept = 0, linetype = 2) +
    labs(x = "rate shifts allowed on extinct lineages", y = "rate shifts not allowed on extinct lineages") +
    ggtitle("mean extinction rate") +
    theme_classic() 

p3 <- dfnetdiv |> 
    ggplot(aes(x = allow, y = disallow, color = name)) +
    geom_point() +
    geom_abline(slope = 1, intercept = 0, linetype = 2) +
    labs(x = "rate shifts allowed on extinct lineages", y = "rate shifts not allowed on extinct lineages") +
    ggtitle("mean netdiv rate") +
    theme_classic() 

p4 <- dfeta |> 
    ggplot(aes(x = allow, y = disallow, color = name)) +
    geom_point() +
    geom_abline(slope = 1, intercept = 0, linetype = 2) +
    labs(x = "rate shifts allowed on extinct lineages", y = "rate shifts not allowed on extinct lineages") +
    ggtitle("shift rate (eta)") +
    theme_classic() 

p5 <- dfNstar |> 
    ggplot(aes(x = allow, y = disallow, color = name)) +
    geom_point() +
    geom_abline(slope = 1, intercept = 0, linetype = 2) +
    labs(x = "rate shifts allowed on extinct lineages", y = "rate shifts not allowed on extinct lineages") +
    ggtitle("number of signif. events (BF > 10)") +
    theme_classic() 


p <- p1 + p2 + p3 + p4 + p5 + plot_layout(ncol = 3) &
    theme(legend.position = "none")

ggsave("figures/scatter.pdf", p, width = 250, height = 200, units = "mm")


##
dfx <- d |> 
    dplyr::filter(rate_shifts == "allow") |>
    select(name, eta, ntip, height)

dfx1 <- left_join(dfmu, dfx, by = "name")
dfx1$diff <- dfx1$disallow - dfx1$allow
dfx1$sq_err <- (dfx1$disallow - dfx1$allow)^2


dfx2 <- left_join(dfeta, dfx, by = "name")
dfx2$diff <- dfx2$disallow - dfx2$allow
dfx2$sq_err <- (dfx2$disallow - dfx2$allow)^2



#p1 <- ggplot(dfx1, aes(x = height, y = diff, label = round(ntip, 1))) + 
p1 <- ggplot(dfx1, aes(x = height, y = diff, label = name)) + 
    geom_point() +
    geom_abline(slope = 0, intercept = 0, linetype = 2) +
    theme_classic() +
    geom_text_repel() +
    scale_x_log10()




