#library(RPesto)
library(ape)
library(tibble)
library(dplyr)
library(ggplot2)


lnFactorial <- function(n){
    if (n == 0){
        res <- 0.0
    }else{
        r = 1.0 / n
        C0 =  0.918938533204672722;
        C1 =  1.0/12.0;
        C3 = -1.0/360.0;
        res = (n + 0.5) * log(n) - n + C0 + r*(C1 + r*r*C3);
    }

    return(res)
}

lnProbTreeShape <- function(phy){
    num_taxa <- length(phy$tip.label)
    res <- (num_taxa - 1.0) * log(2) - lnFactorial(num_taxa);
    return(res)
}


#phy <- read.tree("data/Actinopterygii_Rabosky2018.tree")
phy <- read.tree("data/conifers/conifers.tre")


phy$node.label <- NULL
newick_string <- ape::write.tree(phy)
phylogeny <- RPesto:::Phylogeny$new(newick_string)

lambda_hat <- 0.1523495744 
mu_hat <- 0.1450639863

sampling_fraction <- 1.0
num_classes <- 5
sd <- 0.587

condition_survival <- FALSE
condition_marginal_survival <- FALSE
condition_root_speciation <- FALSE

tol <- 1e-4


foo <- function(x) {
    extinction_approximation <- FALSE
    phylogeny$bds_likelihood(lambda_hat, mu_hat, x[1], sampling_fraction, sd, num_classes, tol, FALSE, condition_survival, condition_marginal_survival, condition_root_speciation, extinction_approximation)
}

baz <- function(x) {
    extinction_approximation <- TRUE
    phylogeny$bds_likelihood(lambda_hat, mu_hat, x[1], sampling_fraction, sd, num_classes, tol, FALSE, condition_survival, condition_marginal_survival, condition_root_speciation, extinction_approximation)
}

  # logarithmic spaced sequence
lseq <- function(from=1, to=100000, length.out=6) {
  exp(seq(log(from), log(to), length.out = length.out))
}

#etas <- lseq(0.0001, 0.01, length.out = 20)
etas <- seq(0.0, 0.01, by = 0.00025)
logls1 <- sapply(etas, foo) + lnProbTreeShape(phy)
logls2 <- sapply(etas, baz) + lnProbTreeShape(phy)

dput(logls1)
dput(logls2)

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
    labs(x = "shift rate (eta)", y = "log likelihood") +
    ggtitle("5 sp and 5 mu (RPesto)")


ggsave("figures/likelhood_curve_conifers.pdf", p, width = 120, height = 90, units = "mm")



#foo(0.001)
