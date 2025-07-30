#library(RPesto)
library(ape)
library(tibble)
library(dplyr)
library(ggplot2)
library(patchwork)


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
num_speciation_classes <- 5
num_extinction_classes <- 1
sd <- 0.587

condition_survival <- FALSE
condition_marginal_survival <- FALSE
condition_root_speciation <- FALSE

tol <- 1e-4


foo <- function(lambda_hat, eta) {
    extinction_approximation1 <- FALSE
    phylogeny$bds_likelihood(lambda_hat, mu_hat, eta, sampling_fraction, sd, num_speciation_classes, num_extinction_classes, tol, FALSE, condition_survival, condition_marginal_survival, condition_root_speciation, extinction_approximation1)
}

baz <- function(lambda_hat, eta) {
    extinction_approximation2 <- TRUE
    phylogeny$bds_likelihood(lambda_hat, mu_hat, eta, sampling_fraction, sd, num_speciation_classes, num_extinction_classes, tol, FALSE, condition_survival, condition_marginal_survival, condition_root_speciation, extinction_approximation2)
}

  # logarithmic spaced sequence
lseq <- function(from=1, to=100000, length.out=6) {
  exp(seq(log(from), log(to), length.out = length.out))
}

#etas <- lseq(0.0001, 0.01, length.out = 20)
#etas <- seq(0.0, 0.01, by = 0.00025)
etas <- seq(0.0, 0.015, length.out = 99)
lambdas <- seq(0.001, 0.22, length.out = 61)


grid <- function(etas, lambdas, f, lower_limit = -25){
    dfs <- list()
    q <- 1L
    for (i in 1:length(lambdas)){
        for (j in 1:length(etas)){
            lnl <- f(lambdas[i], etas[j]) + lnProbTreeShape(phy)

            df <- tibble(
                         "eta" = etas[j],
                         "lambda_hat" = lambdas[i],
                         "logl" = lnl,
                         "shifts" = "allow"
                         )
            dfs[[q]] <- df
            q <- q + 1L
        }
    }
    df <- bind_rows(dfs)
    df$delta_logl <- df$logl - max(df$logl)

    #lower_limit <- -25.0
    df$delta_logl[df$delta_logl < lower_limit] <- lower_limit

    return(df)
}

df1 <- grid(etas, lambdas, foo)
df2 <- grid(etas, lambdas, baz)

#df1$delta_logl <- -1.0 * df1$delta_logl
#df1$delta_logl <- df1$delta_logl + rnorm(20*20, mean=0, sd = 0.001)


p1 <- ggplot(df1, aes(y = lambda_hat, x = eta, z = delta_logl)) +
    geom_contour(colour = "black") +
    theme_classic() +
    ggtitle("allow") +
    labs(y = "mean speciation rate (lambda hat)", x = "shift rate (eta)") +
    xlim(min(etas), max(etas)) +
    geom_point(data=subset(df1, delta_logl == 0.0), color = "red")

p2 <- ggplot(df2, aes(y = lambda_hat, x = eta, z = delta_logl)) +
    geom_contour(colour = "black") +
    theme_classic() +
    ggtitle("disallow") +
    labs(y = "mean speciation rate (lambda hat)", x = "shift rate (eta)") +
    xlim(min(etas), max(etas)) +
    geom_point(data=subset(df2, delta_logl == 0.0), color = "red")


p <- p1 | p2

ggsave("figures/logl_surface.pdf", p, width = 200, height = 120, units = "mm")
