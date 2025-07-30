library(RPesto)
library(ape)
library(ggtree)
library(ggplot2)
library(patchwork)
library(tibble)
library(dplyr)

metadata <- read.csv("data/metadata.csv") |> 
    as_tibble() |>
    filter(skip == 0)

num_classes <- 7

condition_survival <- FALSE
condition_marginal_survival <- TRUE
condition_root_speciation <- TRUE

sampling_fraction <- 0.1183913043


phy <- read.tree("data/Asteraceae_Palazzesi2022.tree")

## condition on mrca only
analysis1 <- fit_bds(phy, sampling_fraction, num_classes = num_classes, condition_survival = FALSE, condition_marginal_survival = FALSE, condition_root_speciation = TRUE, extinction_approximation = TRUE, verbose = T)
## condition on mrca and per-category survival
analysis2 <- fit_bds(phy, sampling_fraction, num_classes = num_classes, condition_survival = TRUE, condition_marginal_survival = FALSE, condition_root_speciation = TRUE, extinction_approximation = TRUE, verbose = T)
## condition on mrca and marginal survival
analysis3 <- fit_bds(phy, sampling_fraction, num_classes = num_classes, condition_survival = FALSE, condition_marginal_survival = TRUE, condition_root_speciation = TRUE, extinction_approximation = TRUE, verbose = T)

analyses <- list(analysis1, analysis2, analysis3)


## greens
low1 <- "#00441b"
high1 <- "#c7e9c0"

# blues
#low1 <- "#08306b"
#high1 <- "#c6dbef"

# reds
#low2 <- "#00441b"
#high2 <- "#c7e9c0"

dot_color <- "#fc9272"
significance_threshold <- 10


th <- max(node.depth.edgelength(analysis1$td@phylo))

scalexformat <- function(x) sprintf("%.0f", th - abs(round(x, 1)))
scalelikformat <- function(x) sprintf("%.2f", round(x, 2))

limits1 <- c(
    min(sapply(analyses, function(x) min(x$td@data$mean_lambda))),
    max(sapply(analyses, function(x) max(x$td@data$mean_lambda)))
    )


p1a <- ggtree(analysis1$td, aes(color = mean_lambda)) +
  ggtitle(paste0("cdt on MRCA")) +
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
  ggtitle(paste0("cdt on MRCA + p.c. survival")) +
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

p1c <- ggtree(analysis2$td, aes(color = mean_lambda)) +
  ggtitle(paste0("cdt on MRCA + marginal survival")) +
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


p <- p1a + p1b + p1c + plot_layout(ncol = 3, guides = "collect") &
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

out_name <- "figures/daisies_conditioning_options.pdf"
width <- 500
height <- 400
ggsave(out_name, p, width = width, height = height, units = "mm")


## box plots
df1 <- as_tibble(analysis1$td)
df1$cdt <- "MRCA"
df2 <- as_tibble(analysis2$td)
df2$cdt <- "MRCA + p.c. survival"
df3 <- as_tibble(analysis3$td)
df3$cdt <- "MRCA + marginal survival"

dfx <- bind_rows(df1, df2, df3)

p2 <- ggplot(dfx, aes(x = as.factor(cdt), y = mean_lambda)) +
    geom_boxplot() + 
    theme_classic() +
    labs(x = "kinds of conditioning", y = "branch-specific speciation rate")

out_name <- "figures/daisies_conditioning_options_boxplot.pdf"
width <- 180
height <- 120
ggsave(out_name, p2, width = width, height = height, units = "mm")






