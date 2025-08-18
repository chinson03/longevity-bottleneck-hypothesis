install.packages(c("renv","targets","tarchetypes","tidyverse","data.table",
                   "ape","phytools","geiger","caper","phylolm","OUwie",
                   "SensiPhy","corHMM","Rphylopars","Biostrings","DECIPHER",
                   "topGO","msigdbr","biomaRt","GenomicRanges","rtracklayer",
                   "metafor","glmmTMB","phangorn", "paleotree"))
renv::init()

## Import amniote tree data from Jiang et al. 2023
amniote_tree_data <- read.csv("data/amniote_tree.csv", header = TRUE, sep = "\t")
clade_list <- split(amniote_tree_data$Species, amniote_tree_data$Clade)

# clades for timetree
clade_lines <- c(unique(amniote_tree_data$Clade))
writeLines(clade_lines, "data/amniote_clades.txt")

# Species for timetree
spp_lines <- c(unique(amniote_tree_data$Species))
spp_lines <- gsub("\\*","",spp_lines)
               
clade_lines <- c(unique(amniote_tree_data$Clade))
writeLines(clade_lines, "data/amniote_clades.txt")
writeLines(spp_lines, "data/amniote_spp.txt")

install.packages("ggtree", "dplyr", "viridis")
library(ggtree)
library(dplyr)
library(viridis)
library(ggplot2)
## Import nwk
tree <- read.tree("data/amniote_spp.nwk")
## Spp. list
tree$tip.label
tree$tip.label <- gsub("_", " ", tree$tip.label)  # Replace underscores with spaces


# Extract genus (handle "Sample" labels)
genus_data <- data.frame(
  label = tree$tip.label,
  genus = ifelse(
    grepl("Sample", tree$tip.label),
    "Sample",
    sapply(strsplit(tree$tip.label, " "), `[`, 1)  # First word = genus
  )
)

# Assign colors (viridis for genera, white for "Sample")
genera <- setdiff(unique(genus_data$genus), "Sample")
genus_colors <- viridis(length(genera), option = "D")  # "D" = viridis
names(genus_colors) <- genera
genus_colors <- c(genus_colors, "Sample" = "#FFFFFF")

# Plot the tree with genus colors
## STOP POINT 19/8/25

## Downloading PhyloPic Silhouettes
install.packages("rphylopic")
library(rphylopic)
# Install if needed
install.packages("rphylopic")

library(rphylopic)
library(dplyr)

sci_name <- tree$tip.label

# Function to fetch and save silhouette for a species list

save_phylopic(img = get_phylopic(get_uuid(sci_name[1])), path = "silhouettes/" + sci_name[1] + ".png", width = 500, height = 500)



outfile <- file.path(outdir, paste0(gsub(" ", "_", sp), ".png"))



plot <- ggtree(tree, branch.length = )

plot + geom_tiplab()

