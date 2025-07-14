library(ape)
library(RPesto)

#sampling_fraction <- 0.25
#phy <- read.tree("data/Lecanoromycetes_Nelsen2020.tree")


sampling_fraction <- 0.3619808307
phy <- read.tree("data/Ericales_Rose2018.tree")

num_classes <- 11

analysis1 <- fit_bds(phy, sampling_fraction, num_classes = num_classes, extinction_approximation = FALSE, verbose = TRUE)
analysis2 <- fit_bds(phy, sampling_fraction, num_classes = num_classes, extinction_approximation = TRUE, verbose = TRUE)


