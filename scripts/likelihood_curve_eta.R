#library(RPesto)
library(ape)
library(tibble)
library(dplyr)
library(ggplot2)


#phy <- read.tree("data/Actinopterygii_Rabosky2018.tree")
#phy <- read.tree("data/Primates_Springer2012.tree")


phy$node.label <- NULL
newick_string <- ape::write.tree(phy)
phylogeny <- RPesto:::Phylogeny$new(newick_string)

lambda_hat <- 0.166225142
mu_hat <- 0.118363802

sampling_fraction <- 0.3691556176
num_classes <- 7
sd <- 0.587

condition_survival <- FALSE
condition_root_speciation <- TRUE

tol <- 1e-6


foo <- function(x) {
    extinction_approximation <- FALSE
    phylogeny$bds_likelihood(lambda_hat, mu_hat, x[1], sampling_fraction, sd, num_classes, tol, FALSE, condition_survival, condition_root_speciation, extinction_approximation)
}

baz <- function(x) {
    extinction_approximation <- TRUE
    phylogeny$bds_likelihood(lambda_hat, mu_hat, x[1], sampling_fraction, sd, num_classes, tol, FALSE, condition_survival, condition_root_speciation, extinction_approximation)
}

  # logarithmic spaced sequence
lseq <- function(from=1, to=100000, length.out=6) {
  exp(seq(log(from), log(to), length.out = length.out))
}

etas <- lseq(0.0001, 0.01, length.out = 20)
logls1 <- sapply(etas, foo)
logls2 <- sapply(etas, baz)

df1 <- tibble(
        "eta" = etas,
        "logl" = logls1,
        "shifts" = "allow"
        )

df2 <- tibble(
        "eta" = etas,
        "logl" = logls2,
        "shifts" = "disallow"
        )

dfx <- bind_rows(df1, df2)


p <- ggplot(dfx, aes(x = eta, y = logl, linetype = shifts)) +
    geom_line() +
    theme_classic() +
    labs(x = "shift rate (eta)", y = "log likelihood")


ggsave("figures/likelhood_curve.pdf", p, width = 100, height = 70, units = "mm")



#foo(0.001)
