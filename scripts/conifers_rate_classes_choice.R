library(RPesto)
library(ape)
library(tibble)
library(ggtree)
library(ggplot2)

num_speciation_classes <- 9
num_extinction_classes <- 9

condition_survival <- TRUE
condition_root_speciation <- TRUE
condition_marginal <- TRUE

sampling_fraction <- 1.0

phy <- read.tree("data/conifers/conifers.tre")

analysis1 <- fit_bds(phy, sampling_fraction, num_speciation_classes = num_speciation_classes, num_extinction_classes = num_extinction_classes, condition_survival = condition_survival, condition_root_speciation = condition_root_speciation, condition_marginal = condition_marginal, extinction_approximation = FALSE, verbose = F)
analysis2 <- fit_bds(phy, sampling_fraction, num_speciation_classes = num_speciation_classes, num_extinction_classes = num_extinction_classes, condition_survival = condition_survival, condition_root_speciation = condition_root_speciation, condition_marginal = condition_marginal, extinction_approximation = TRUE, verbose = F)

num_speciation_classes <- 5
num_extinction_classes <- 5

analysis3 <- fit_bds(phy, sampling_fraction, num_speciation_classes = num_speciation_classes, num_extinction_classes = num_extinction_classes, condition_survival = condition_survival, condition_root_speciation = condition_root_speciation, condition_marginal = condition_marginal, extinction_approximation = FALSE, verbose = F)
analysis4 <- fit_bds(phy, sampling_fraction, num_speciation_classes = num_speciation_classes, num_extinction_classes = num_extinction_classes, condition_survival = condition_survival, condition_root_speciation = condition_root_speciation, condition_marginal = condition_marginal, extinction_approximation = TRUE, verbose = F)

analyses <- list(analysis1, analysis2, analysis3, analysis4)


limits <- c(
    min(sapply(analyses, function(x) min(x$td@data$mean_mu))),
    max(sapply(analyses, function(x) max(x$td@data$mean_mu)))
    )

# reds
low1 <- "#990000"
high1 <- "#ffb3b3"

significance_threshold <- 10


p1 <- ggtree(analysis1$td, aes(color = mean_mu)) +
      ggtitle(paste0("9x9 rate classes (allow)")) +
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
      ggtitle(paste0("9x9 rate classes (disallow)")) +
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

p3 <- ggtree(analysis3$td, aes(color = mean_mu)) +
      ggtitle(paste0("5x5 rate classes (allow)")) +
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

p4 <- ggtree(analysis4$td, aes(color = mean_mu)) +
      ggtitle(paste0("5x5 rate classes (disallow)")) +
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


px <- p1 + p2 + p3 + p4 + plot_layout(ncol = 4)




