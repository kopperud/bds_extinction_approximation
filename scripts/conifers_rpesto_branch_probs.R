#library(RPesto)
library(ape)
library(tibble)
library(dplyr)


write_times <- function(x, fname, varname){
    n_times <- length(x$t)

    cat(paste0(varname, " = ["), file = fname)
    for (i in 1:n_times){
        cat(x$t[i], file = fname, append = TRUE) 
        if (i < n_times){
            cat(",", file = fname, append = TRUE)
        }
    }
    cat("]", file = fname, append = TRUE)
}

write_probs <- function(x, fname, varname){
    n_times <- length(x$t)
    num_categories <- dim(x$probs)[2]

    cat(paste0(varname, " = ["), file = fname)
    for (i in 1:n_times){
        cat("[", file = fname, append = TRUE)
        for (j in 1:num_categories){
            cat(x$probs[i,j], file = fname, append = TRUE)
            if (j < num_categories){
                cat(",", file = fname, append = TRUE)
            }
        }
        cat("]", file = fname, append = TRUE)
        if (i < n_times){
            cat(",", file = fname, append = TRUE)
        }
    }
    cat("]", file = fname, append = TRUE)
}



phy <- read.tree("data/conifers/conifers.tre")

phy$node.label <- NULL
newick_string <- ape::write.tree(phy)
phylogeny <- RPesto:::Phylogeny$new(newick_string)

lambda_hat <- 0.1523495744 
mu_hat <- 0.1450639863
#eta <- 0.0009587719
eta <- 0.05

sampling_fraction <- 1.0
num_classes <- 5
num_categories <- num_classes ^2
sd <- 0.587

condition_survival <- FALSE
condition_marginal_survival <- FALSE
condition_root_speciation <- FALSE

tol <- 1e-8

end_time <- 5.0

extinction_approximation <- FALSE
x <- RPesto:::branch_probability_bds(lambda_hat, mu_hat, eta, sampling_fraction, sd, 5, end_time, tol, extinction_approximation)

extinction_approximation <- TRUE
y <- RPesto:::branch_probability_bds(lambda_hat, mu_hat, eta, sampling_fraction, sd, 5, end_time, tol, extinction_approximation)



# print probs and times
write_times(x, "/home/bkopper/times_rpesto_allow.txt", "times_rpesto_allow")
write_probs(x, "/home/bkopper/probs_rpesto_allow.txt", "probs_rpesto_allow")

write_times(y, "/home/bkopper/times_rpesto_disallow.txt", "times_rpesto_disallow")
write_probs(y, "/home/bkopper/probs_rpesto_disallow.txt", "probs_rpesto_disallow")

# print times


