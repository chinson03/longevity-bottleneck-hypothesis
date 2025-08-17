install.packages(c("renv","targets","tarchetypes","tidyverse","data.table",
                   "ape","phytools","geiger","caper","phylolm","OUwie",
                   "SensiPhy","corHMM","Rphylopars","Biostrings","DECIPHER",
                   "topGO","msigdbr","biomaRt","GenomicRanges","rtracklayer",
                   "metafor","glmmTMB","phangorn", "paleotree"))
renv::init()

library(ape); library(phytools)

## Import amniote tree data from Jiang et al. 2023
amniote_tree_data <- read.csv("data/amniote_tree.csv", header = TRUE, sep = "\t")
clade_list <- split(amniote_tree_data$Species, amniote_tree_data$Clade)

# Merge spp + clade for timetree
clade_lines <- sapply(names(clade_list), function(cl){
  paste0(cl, ": ", paste(clade_list[[cl]], collapse=", "))
})

writeLines(clade_lines, "data/amniote_clades.txt")


tree <- read.tree("trees/amniotes_time_calibrated.tre")
tree <- keep.tip(tree, my_species_vector) |> chronos(lambda = 1)


