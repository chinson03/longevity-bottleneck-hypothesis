## Gene loss analysis
## Charlie Hinson 6/8/25

##libraries
library(ggplot2)
library(ggtree)
library(rvest)
library(httr)
library(jsonlite)
## Lifespan + Ageing traits
anage <- read.delim("data/anage_data.txt")
## Regeneration traits (E.g. tooth regrow, limb regen)
## Generating dataframe, sourcing regeneration genes and traits from https://ngdc.cncb.ac.cn/regeneration/index
## Using binary categories for simplicity
regen_traits <- data.frame("Class" <- anage$Class,"Genus" <- anage$Genus, "Species" <- anage$Species, "Common.name" <- anage$Common.name, "Regen_present" <- rep(0, length(anage$Species)), "Limb_regen" <- rep(0, length(anage$Species)), "Oocyte_regen" <- rep(0, length(anage$Species)), "Tooth_replace" <- rep(0, length(anage$Species)), "Indeterminate_growth" <- rep(0, length(anage$Species)), "Negligible_senescence" <- rep(0, length(anage$Species)))
## Create CSV
write.csv(regen_traits, "data/regen_traits.csv", row.names = FALSE)
## Searching spp. for regeneration keyword
## Separating amphibians for https://amphibiaweb.org/
## https://amphibiaweb.org/amphib_dump.xml
amphibians <- regen_traits[regen_traits$X.class.....anage.Class == "Amphibia",]

## Reptiles from https://reptile-database.reptarium.cz/search?search=regeneration&submit=Search