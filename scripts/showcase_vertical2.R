library(ape)
library(ggtree)
library(ggplot2)
#library(patchwork)
library(cowplot)

# blues
low1 <- "#08306b"
high1 <- "#c6dbef"

# greens
low2 <- "#00441b"
high2 <- "#c7e9c0"

# reds
low3 <- "#990000"
high3 <- "#ffb3b3"

#dot_color <- "#fc9272"
dot_color <- "#c7e9c0"
dot_color <- "#ffff96"
dot_color <- "#ffffff"
dot_color <- "#e6e6e6"

bgcolor="white"
fgcolor="black"

significance_threshold <- 10


fname <- "output/JO2016.RData"

# white background with a box
p0w <- ggplot() + 
    theme_bw() +
    theme(
      panel.grid.major = element_blank(), 
      panel.grid.minor = element_blank(),
      panel.background = element_rect(fill = "white", colour = NA),
      plot.background = element_rect(fill = "white", colour = NA),
      axis.line = element_line(colour = "black")
    ) 

# white background without a box
p0w2 <- ggplot() + 
    theme(
  panel.grid.major = element_blank(), 
  panel.grid.minor = element_blank(),
  panel.background = element_rect(fill = "white", colour = NA),
  plot.background = element_rect(fill = "white", colour = NA),
  axis.line = element_line(colour = "black")
)  

get_legend2 <- function(plot, legend = NULL) {
  if (is_ggplot(plot)) {
    gt <- ggplotGrob(plot)
  } else {
    if (is.grob(plot)) {
      gt <- plot
    } else {
      stop("Plot object is neither a ggplot nor a grob.")
    }
  }
  pattern <- "guide-box"
  if (!is.null(legend)) {
    pattern <- paste0(pattern, "-", legend)
  }
  indices <- grep(pattern, gt$layout$name)
  not_empty <- !vapply(
    gt$grobs[indices], 
    inherits, what = "zeroGrob", 
    FUN.VALUE = logical(1)
  )
  indices <- indices[not_empty]
  if (length(indices) > 0) {
    return(gt$grobs[[indices[1]]])
  }
  return(NULL)
}

foo <- function(fname, outname, width, height){
    bn <- gsub("\\.RData", "", fname)
    bn <- gsub("output/", "", bn)

    load(fname) ## loads the `analyses` variable

    analysis1 <- analyses[[1]]
    analysis2 <- analyses[[2]]
    analyses[[3]] <- NULL
    analyses[[4]] <- NULL
    analyses[[5]] <- NULL

    th <- max(node.depth.edgelength(analysis1$td@phylo))

    scalexformat <- function(x) sprintf("%.0f", th - abs(round(x, 1)))
    scalelikformat <- function(x) sprintf("%.2f", round(x, 2))

    limits1 <- c(
        min(sapply(analyses, function(x) min(x$td@data$mean_lambda))),
        max(sapply(analyses, function(x) max(x$td@data$mean_lambda)))
        )

    limits2 <- c(
        min(sapply(analyses, function(x) min(x$td@data$mean_mu))),
        max(sapply(analyses, function(x) max(x$td@data$mean_mu)))
        )

    ## speciation rate
    p1a <- ggtree(analysis1$td, aes(color = mean_lambda)) +
      #ggtitle(paste0("allowed")) +
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
      scale_x_continuous(labels = scalexformat) +
      scale_x_reverse(labels = scalexformat) +
      theme(legend.position = "none") +
      coord_flip() +
      theme_nothing()

    p1b <- ggtree(analysis2$td, aes(color = mean_lambda)) +
      #ggtitle(paste0("not allowed")) +
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
      theme(legend.position = "none") +
      coord_flip() +
      theme_nothing()

    ## extinction rates
    p2a <- ggtree(analysis1$td, aes(color = mean_mu)) +
      #ggtitle(paste0("allowed")) +
      scale_colour_gradient(
        name = "extinction rate ", 
        low = low3,
        high = high3,
        limits = limits2,
        space = "Lab",
        na.value = "grey50",
        guide = "colourbar",
        aesthetics = "colour"
      ) +
      geom_point2(aes(subset=(shift_bf > significance_threshold)), size = 1.5, color = "black", fill = dot_color, shape = 21, stroke = 0.5) +
      scale_x_continuous(labels = scalexformat) +
      scale_x_reverse(labels = scalexformat) +
      theme(legend.position = "none") +
      coord_flip() +
      theme_nothing()

    p2b <- ggtree(analysis2$td, aes(color = mean_mu)) +
      #ggtitle(paste0("not allowed")) +
      scale_colour_gradient(
        name = "extinction rate ", 
        low = low3,
        high = high3,
        limits = limits2,
        space = "Lab",
        na.value = "grey50",
        guide = "colourbar",
        aesthetics = "colour"
      ) +
      theme(legend.position = "none") +
      geom_point2(aes(subset=(shift_bf > significance_threshold)), size = 1.5, color = "black", fill = dot_color, shape = 21, stroke = 0.5) +
      coord_flip() +
      theme_nothing()

    first_col <- plot_grid(p0w, p0w, p0w2, ncol = 1, rel_heights = c(0.45, 0.45, 0.1)) +
        draw_plot_label(
                    label = c("disallow", "allow"),
                    x = 0.5,
                    y = c(0.1 + 0.45/2,0.1+ 0.45 + 0.5*0.45),
                    hjust = 0.5,
                    vjust = 0.5,
                    size = 10,
                    angle=90
        )

    leg_theme <- theme(
            plot.title = element_text(hjust = 0.5, size = 15),
            legend.position = "bottom",
            plot.margin = unit(c(0,0,0,0), "mm"),
            axis.title.x = element_blank(),
            axis.title.y = element_blank(),
            legend.key.size = unit(7, 'mm'), #change legend key size
            legend.key.height = unit(8, 'mm'), #change legend key height
            legend.key.width = unit(10, 'mm'), #change legend key width
            legend.title = element_text(size=14), #change legend title font size
            legend.text = element_text(size=9) #change legend text font size
            ) 

    leg1 <- get_legend2(p1a + leg_theme)
    spec_col <- plot_grid(p1a, p1b, leg1, ncol = 1, rel_heights = c(0.45, 0.45, 0.1))
    leg2 <- get_legend2(p2a + leg_theme)
    netdiv_col <- plot_grid(p2a, p2b, leg2, ncol = 1, rel_heights = c(0.45, 0.45, 0.1))

    p <- plot_grid(first_col, spec_col, netdiv_col, ncol = 3, rel_widths = c(0.04, 0.48, 0.48))

    #p <- p1a + p2a + p1b + p2b + plot_layout(ncol = 2, guides = "collect") &
          #theme(
            #plot.title = element_text(hjust = 0.5, size = 16),
            #legend.position = "bottom",
            #plot.margin = unit(c(0,0,0,0), "mm"),
            #axis.title.x = element_blank(),
            #axis.title.y = element_blank(),
            #legend.key.size = unit(10, 'mm'), #change legend key size
            #legend.key.height = unit(10, 'mm'), #change legend key height
            #legend.key.width = unit(10, 'mm'), #change legend key width
            #legend.title = element_text(size=14), #change legend title font size
            #legend.text = element_text(size=10) #change legend text font size
            #) 

    out_name <- paste0(outname)
    ggsave(out_name, p, width = width, height = height, units = "mm")
}

#foo("output/JO2016.RData", "figures/Corvids.pdf", 400, 250)
#foo("output/Salvia_Kriebel2019.RData", "figures/Salvia.pdf", 400, 250)
#foo("output/Aristolochiaceae_Allio2021.RData", "figures/Butterflies.pdf", 400, 300)
#foo("output/Ericales_Rose2018.RData", "figures/Ericales.pdf", 400, 250)
foo("output/pg2575.RData", "figures/Passeriformes.pdf", 150*1.6, 120)
#foo("output/conifers.Rdata", "figures/conifers.pdf", 150*1.6, 150)
foo("output/Pinophyta_Leslie2018.RData", "figures/conifers_leslie2018.pdf", 150*1.6, 120)
foo("output/Pinophyta_Leslie2012.RData", "figures/conifers_leslie2012.pdf", 150*1.6, 120)
foo("output/S2015.RData", "figures/galliformes.pdf", 150*1.6, 120)

