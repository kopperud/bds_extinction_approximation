library(ape)
library(ggtree)
library(ggplot2)
library(patchwork)

# blues
low1 <- "#08306b"
high1 <- "#c6dbef"

# greens
low2 <- "#00441b"
high2 <- "#c7e9c0"

dot_color <- "#fc9272"

bgcolor="white"
fgcolor="black"

significance_threshold <- 10


fname <- "output/JO2016.RData"

foo <- function(fname, outname, width, height){
    bn <- gsub("\\.RData", "", fname)
    bn <- gsub("output/", "", bn)

    load(fname) ## loads the `analyses` variable


    analysis1 <- analyses[[1]]
    analysis2 <- analyses[[2]]

    th <- max(node.depth.edgelength(analysis1$td@phylo))

    scalexformat <- function(x) sprintf("%.0f", th - abs(round(x, 1)))
    scalelikformat <- function(x) sprintf("%.2f", round(x, 2))

    limits1 <- c(
        min(sapply(analyses, function(x) min(x$td@data$mean_lambda))),
        max(sapply(analyses, function(x) max(x$td@data$mean_lambda)))
        )


    limits2 <- c(
        min(sapply(analyses, function(x) min(x$td@data$mean_netdiv))),
        max(sapply(analyses, function(x) max(x$td@data$mean_netdiv)))
        )

    p1a <- ggtree(analysis1$td, aes(color = mean_lambda)) +
      ggtitle(paste0("allowed")) +
      scale_colour_gradient(
        name = "speciation rate", 
        low = low1,
        high = high1,
        limits = limits1,
        space = "Lab",
        na.value = "grey50",
        guide = "colourbar",
        aesthetics = "colour"
      ) +
      geom_point2(aes(subset=(shift_bf > significance_threshold)), size = 1.5, color = "black", fill = dot_color, shape = 21, stroke = 0.5) +
      scale_x_continuous(labels = scalexformat) 

    p1b <- ggtree(analysis2$td, aes(color = mean_lambda)) +
      ggtitle(paste0("not allowed")) +
      scale_colour_gradient(
        name = "speciation rate", 
        low = low1,
        high = high1,
        limits = limits1,
        space = "Lab",
        na.value = "grey50",
        guide = "colourbar",
        aesthetics = "colour"
      ) +
      geom_point2(aes(subset=(shift_bf > significance_threshold)), size = 1.5, color = "black", fill = dot_color, shape = 21, stroke = 0.5) +
      scale_x_reverse(labels = scalexformat) 

    p2a <- ggtree(analysis1$td, aes(color = mean_netdiv)) +
      ggtitle(paste0("allowed")) +
      scale_colour_gradient(
        name = "net-diversification rate", 
        low = low2,
        high = high2,
        limits = limits2,
        space = "Lab",
        na.value = "grey50",
        guide = "colourbar",
        aesthetics = "colour"
      ) +
      geom_point2(aes(subset=(shift_bf > significance_threshold)), size = 1.5, color = "black", fill = dot_color, shape = 21, stroke = 0.5) +
      scale_x_continuous(labels = scalexformat) 

    p2b <- ggtree(analysis2$td, aes(color = mean_netdiv)) +
      ggtitle(paste0("not allowed")) +
      scale_colour_gradient(
        name = "net-diversification rate", 
        low = low2,
        high = high2,
        limits = limits2,
        space = "Lab",
        na.value = "grey50",
        guide = "colourbar",
        aesthetics = "colour"
      ) +
      geom_point2(aes(subset=(shift_bf > significance_threshold)), size = 1.5, color = "black", fill = dot_color, shape = 21, stroke = 0.5) +
      scale_x_reverse(labels = scalexformat) 



    p <- p1a + p1b + p2a + p2b + plot_layout(ncol = 4, guides = "collect") &
          theme(
            plot.title = element_text(hjust = 0.5, size = 16),
            legend.position = "bottom",
            plot.margin = unit(c(0,0,0,0), "mm"),
            axis.title.x = element_blank(),
            axis.title.y = element_blank(),
            legend.key.size = unit(1, 'cm'), #change legend key size
            legend.key.height = unit(1, 'cm'), #change legend key height
            legend.key.width = unit(1.5, 'cm'), #change legend key width
            legend.title = element_text(size=14), #change legend title font size
            legend.text = element_text(size=10) #change legend text font size
            ) 

    out_name <- paste0(outname)
    ggsave(out_name, p, width = width, height = height, units = "mm")
}

foo("output/JO2016.RData", "figures/Corvids.pdf", 400, 250)
foo("output/Salvia_Kriebel2019.RData", "figures/Salvia.pdf", 400, 250)
foo("output/Aristolochiaceae_Allio2021.RData", "figures/Butterflies.pdf", 400, 300)
foo("output/Ericales_Rose2018.RData", "figures/Ericales.pdf", 400, 250)

