## Gene loss analysis
## Charlie Hinson 6/8/25

##libraries
library(ggplot2, ggtree, rvest, httr, jsonlite, tidyr, purrr, XML, caper)

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

GenusList <- xml_text(xml_find_all(amphibians, ".//genus"))
GenusList <- gsub("\n", "", GenusList)

SpeciesList <- xml_text(xml_find_all(amphibians, ".//specificepithet"))
SpeciesList <- gsub("\n", "", SpeciesList)

DescriptionList <- xml_text(xml_find_all(amphibians, ".//description"))
DescriptionList <- gsub("\n", "", DescriptionList)

amphib_df <- data.frame(Genus = GenusList, Species = SpeciesList, Description = DescriptionList, stringsAsFactors = FALSE)
amphib_df$regen_present <- ifelse(grepl("regenerat", amphib_df$Description, ignore.case = TRUE), 1, 0)
amphib_df[amphib_df$regen_present == 1, ]
sum

## 15 Amphibians with "regenerate/regeneration" in description
## Are these spp. present in anage database?
anage_amphib <- anage[anage$Class == "Amphibia", ]
anage_amphib$regen_present


sum(anage_amphib$regen_present)

anage_amphib$full_name <- paste(anage_amphib$Genus, anage_amphib$Species)
amphib_df$full_name    <- paste(amphib_df$Genus, amphib_df$Species)

common_species <- intersect(anage_amphib$full_name, amphib_df$full_name)

common_df <- data.frame(
  Genus   = sub(" .*", "", common_species),      # take text before first space
  Species = sub("^[^ ]+ ", "", common_species),  # take text after first space
  stringsAsFactors = FALSE
)

common_df

merged_df <- merge(anage_amphib, amphib_df,
                   by = c("Genus", "Species"))

merged_df
sum(merged_df$regen_present)  # from anage only 1




## Searching reptiles for regeneration keyword
## Reptiles from https://reptile-database.reptarium.cz/search?search=regeneration&submit=Search
## Downloaded entire database, converted to csv

