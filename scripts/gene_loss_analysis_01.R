## Gene loss analysis
## Charlie Hinson 6/8/25

##libraries
library(ggplot2)
library(ggtree)
library(rvest)
library(httr)
library(jsonlite)
library(tidyr)
library(purrr)
library(xml2)
## Lifespan + Ageing traits
anage <- read.delim("data/anage_data.txt")

## Regeneration traits (E.g. tooth regrow, limb regen)
## Creating dataframe, sourcing regeneration genes from https://ngdc.cncb.ac.cn/regeneration/index

## Genes must be related to below categories, i.e.
## 1. Is regeneration present at all?
## In this database, only 6 spp. are listed. Will need to find alternative source for if regen is present in any given species.
## 2. Limb regeneration
## Combining bone, muscle, and cartilage data for limb_regen
## 3. Oocyte regen
## 4. Tooth replacement
## 5. Indeterminate growth
## 6. Negligible senescence

gen_age <- read.csv("data/genage_models.csv", header = TRUE)
head(gen_age)

regen_genes <- data.frame(read.csv("data/regen_genes.csv", header = TRUE))
unique(regen_genes$Species)
head(regen_genes)
## Sourcing regen traits from amphibian + reptilian databases
## Creating dataframe
## Using binary categories for simplicity
regen_traits <- data.frame("Class" <- anage$Class,"Genus" <- anage$Genus, "Species" <- anage$Species, "Common.name" <- anage$Common.name, "Regen_present" <- rep(0, length(anage$Species)), "Limb_regen" <- rep(0, length(anage$Species)), "Oocyte_regen" <- rep(0, length(anage$Species)), "Tooth_replace" <- rep(0, length(anage$Species)), "Indeterminate_growth" <- rep(0, length(anage$Species)), "Negligible_senescence" <- rep(0, length(anage$Species)))
## Create CSV
write.csv(regen_traits, "data/regen_traits.csv", row.names = FALSE)

## Searching spp. for regeneration keyword
## Separating amphibians for https://amphibiaweb.org/
## https://amphibiaweb.org/amphib_dump.xml
amphibians <- read_xml("data/amphib_dump.xml")
## Take species nodes
species_nodes <- xml_find_all(amphibians, ".//species")
## Extract text if present
get_node_text <- function(node, xpath) {
  child <- xml_find_first(node, xpath)
  if (length(child) > 0) xml_text(child) else NA_character_
}

xml_structure(amphibians)



amphibians <- regen_traits[regen_traits$X.class.....anage.Class == "Amphibia",]




## Reptiles from https://reptile-database.reptarium.cz/search?search=regeneration&submit=Search

