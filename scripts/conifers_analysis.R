library(RPesto)
library(ape)
library(tibble)

num_classes <- 7

condition_survival <- FALSE
condition_marginal_survival <- TRUE
condition_root_speciation <- TRUE

sampling_fraction <- 1.0

phy <- read.tree("data/conifers/conifers.tre")

analysis1 <- fit_bds(phy, sampling_fraction, num_classes = num_classes, condition_survival = condition_survival, condition_marginal_survival = condition_marginal_survival, condition_root_speciation = condition_root_speciation, extinction_approximation = FALSE, verbose = F)
analysis2 <- fit_bds(phy, sampling_fraction, num_classes = num_classes, condition_survival = condition_survival, condition_marginal_survival = condition_marginal_survival, condition_root_speciation = condition_root_speciation, extinction_approximation = TRUE, verbose = F)



analyses <- list(analysis1, analysis2)

s <- paste0("output/conifers.Rdata")
save(analyses, file = s)


