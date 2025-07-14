library(ape)
library(ggtree)
library(ggplot2)
library(patchwork)


low1 <- "#990000"
high1 <- "#ffb3b3"

low2 <- "#00441b"
high2 <- "#c7e9c0"

dot_color <- "#fc9272"

significance_threshold <- 10


fnames <- Sys.glob("output/*.RData")

for (fname in fnames){
    bn <- gsub("\\.RData", "", fname)
    bn <- gsub("output/", "", bn)

    load(fname) ## loads the `analyses` variable

    analysis1 <- analyses[[1]]
    analysis2 <- analyses[[2]]

    limits <- c(
        min(sapply(analyses, function(x) min(x$td@data$mean_mu))),
        max(sapply(analyses, function(x) max(x$td@data$mean_mu)))
        )

    p1 <- ggtree(analysis1$td, aes(color = mean_mu)) +
      ggtitle(paste0("Rate shifts allowed on extinct lineages")) +
      scale_colour_gradient(
        name = "extinction rate", 
        low = low1,
        high = high1,
        limits = limits,
        space = "Lab",
        na.value = "grey50",
        guide = "colourbar",
        aesthetics = "colour"
      ) +
      geom_point2(aes(subset=(shift_bf > significance_threshold)), size = 1.5, color = "black", fill = dot_color, shape = 21, stroke = 0.5)

    p2 <- ggtree(analysis2$td, aes(color = mean_mu)) +
      ggtitle(paste0("Rate shifts not allowed on extinct lineages")) +
      scale_colour_gradient(
        name = "extinction rate", 
        low = low1,
        high = high1,
        limits = limits,
        space = "Lab",
        na.value = "grey50",
        guide = "colourbar",
        aesthetics = "colour"
      ) +
      geom_point2(aes(subset=(shift_bf > significance_threshold)), size = 1.5, color = "black", fill = dot_color, shape = 21, stroke = 0.5) +
      scale_x_reverse()

    p <- p1 + p2 + plot_layout(ncol = 2, guides = "collect") &
          theme(
            plot.title = element_text(hjust = 0.5, size = 16),
            legend.position = "bottom",
            theme(plot.margin = unit(c(0,0,0,0), "mm")),
            axis.title.x = element_blank(),
            axis.title.y = element_blank()
            )


    out_name <- paste0("figures/extinction/", bn, "_extinction.pdf")
    ggsave(out_name, p, width = 300, height = 400, units = "mm")
}


#d1 <- as_tibble(analysis1$td)
#d2 <- as_tibble(analysis2$td)
#
#mean_branch_mu1 <- sum(d1$branch.length * d1$mean_mu) / sum(d1$branch.length)
#mean_branch_mu2 <- sum(d2$branch.length * d2$mean_mu) / sum(d2$branch.length)
#
#print(paste0("mean branch extinction rate: ", mean_branch_mu1, " (rate shifts allowed on extinct lineages)"))
#print(paste0("mean branch extinction rate: ", mean_branch_mu2, " (rate shifts not allowed on extinct lineages)"))






