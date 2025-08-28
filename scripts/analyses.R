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

#fnames <- Sys.glob("data/*.tree")
#baz <- function(x){
#   phy <- read.nexus(x)
#   write.tree(phy, x)

num_speciation_classes <- 9
num_extinction_classes <- 1

condition_survival <- FALSE
condition_root_speciation <- TRUE
condition_marginal <- TRUE

if (TRUE){

    for (i in 1:nrow(metadata)){
        fname <- metadata[i,][["Filename"]]
        bn <- gsub("\\.tree", "", fname)
        print(fname)

        if (grepl("Rosidae_Sun2020", fname)){
            next
        }

        #if (grepl("Polypodiophyta_Nitta2022", fname)){
            #next
        #}

        sampling_fraction <- metadata[i,][["P.extant.sampling"]]


        phy <- read.tree(paste0("data/", fname))

        if (length(phy$tip.label) < 20000){
            num_speciation_classes <- 5
            num_extinction_classes <- 5

            analysis1 <- fit_bds(phy, sampling_fraction, num_speciation_classes = num_speciation_classes, num_extinction_classes = num_extinction_classes, condition_survival = condition_survival, condition_root_speciation = condition_root_speciation, condition_marginal = condition_marginal, extinction_approximation = FALSE, verbose = F)
            analysis2 <- fit_bds(phy, sampling_fraction, num_speciation_classes = num_speciation_classes, num_extinction_classes = num_extinction_classes, condition_survival = condition_survival, condition_root_speciation = condition_root_speciation, condition_marginal = condition_marginal, extinction_approximation = TRUE, verbose = F)


            num_speciation_classes <- 5
            num_extinction_classes <- 1
            analysis3 <- fit_bds(phy, sampling_fraction, num_speciation_classes = num_speciation_classes, num_extinction_classes = num_extinction_classes, condition_survival = condition_survival, condition_root_speciation = condition_root_speciation, condition_marginal = condition_marginal, extinction_approximation = FALSE, verbose = F)
            analysis4 <- fit_bds(phy, sampling_fraction, num_speciation_classes = num_speciation_classes, num_extinction_classes = num_extinction_classes, condition_survival = condition_survival, condition_root_speciation = condition_root_speciation, condition_marginal = condition_marginal, extinction_approximation = TRUE, verbose = F)

            analyses <- list(analysis1, analysis2, analysis3, analysis4, sampling_fraction)

            s <- paste0("output/", bn, ".RData")
            save(analyses, file = s)
        }

    }

}


metadata2 <- read.csv("data/77_phylos/dataset_summary.csv") |> 
    as_tibble() 

filenames <- Sys.glob("data/77_phylos/*/*.txt")

for (fname in filenames){
    dname <- strsplit(fname, "/")[[1]][3]

    sampling_fraction <- metadata2[metadata2$Directory == dname,][["globalSamplingFraction"]]

    print(fname)
    phy <- read.tree(fname)

    if (length(phy$tip.label) < 20000){
        num_speciation_classes <- 5
        num_extinction_classes <- 5

        analysis1 <- fit_bds(phy, sampling_fraction, num_speciation_classes = num_speciation_classes, num_extinction_classes = num_extinction_classes, condition_survival = condition_survival, condition_root_speciation = condition_root_speciation, condition_marginal = condition_marginal, extinction_approximation = FALSE, verbose = F)
        analysis2 <- fit_bds(phy, sampling_fraction, num_speciation_classes = num_speciation_classes, num_extinction_classes = num_extinction_classes, condition_survival = condition_survival, condition_root_speciation = condition_root_speciation, condition_marginal = condition_marginal, extinction_approximation = TRUE, verbose = F)

        num_speciation_classes <- 5
        num_extinction_classes <- 1
        analysis3 <- fit_bds(phy, sampling_fraction, num_speciation_classes = num_speciation_classes, num_extinction_classes = num_extinction_classes, condition_survival = condition_survival, condition_root_speciation = condition_root_speciation, condition_marginal = condition_marginal, extinction_approximation = FALSE, verbose = F)
        analysis4 <- fit_bds(phy, sampling_fraction, num_speciation_classes = num_speciation_classes, num_extinction_classes = num_extinction_classes, condition_survival = condition_survival, condition_root_speciation = condition_root_speciation, condition_marginal = condition_marginal, extinction_approximation = TRUE, verbose = F)

        analyses <- list(analysis1, analysis2, analysis3, analysis4, sampling_fraction)

        s <- paste0("output/", dname, ".RData")
        save(analyses, file = s)
    }
}

