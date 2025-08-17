## Bottleneck Hypothesis Testing
## Finding evidence of gene deletion

## Importing libraries
library("rentrez")
library("ggplot2")
library("readr")
library("patchwork")
library("tidyr")
library("dplyr")

## First, compare longevity between clades
## Make simple jitter plot of max. longevity vs. clade
## import
drugage <- read.csv("drugage.csv", header = TRUE)

get_pub_year <- function(pmid) {
    # Fetch the summary
    summary <- entrez_summary(db = "pubmed", id = pmid)
    
    # Get the pubdate field
    pub_date <- summary$pubdate
    
    # Extract year (first 4 digits)
    year <- substr(pub_date, 1, 4)
    return(year)
  }

drugage$year <- sapply(drugage$pubmed_id, get_pub_year)

longevity_data <- read.delim("anage_data.txt", header = TRUE)
## Exploring
head(longevity_data)
unique(longevity_data$Specimen.origin)
## Captive specimens may skew results

## Relevant columns:
## Kingdom-Spp., common name, adult weight, growth rate, max. longevity

unique(longevity_data$Class)
## Only need chordates for simplicity, can adjust to include broader clades later; e.g. cnidaria
unique(longevity_data$Phylum)
chord_data <- longevity_data[(longevity_data$Phylum %in% c("Chordata")),]
## Check chordate classes
unique(chord_data$Class) ## used wrong df first time showed schizzosaccharomyces, adjusted
## Remove low-quality data
## Exploring
unique(chord_data$Data.quality) # acceptable, low, questionable, high
# Start w removing questionable + low REMOVES 611 ENTRIES
chord_data_filtered <- chord_data[!(chord_data$Data.quality %in% c("low", "questionable")),]
summary(chord_data_filtered) # 3966 entries
## EXPERIMENTAL logarithm to max longevity
chord_data_filtered$log.Maximum.longevity..yrs. <- log(chord_data_filtered$Maximum.longevity..yrs.)
## Creating body mass: max longevity ratio
chord_data_filtered$log.bodymass.to.longevity.ratio <- log(chord_data_filtered$Body.mass..g./chord_data_filtered$Maximum.longevity..yrs.)
## Plotting
ggplot(chord_data_filtered)+geom_boxplot(shape = 4, aes(Class,log.bodymass.to.longevity.ratio))+theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1), panel.grid = element_blank())
## Cart. fishes most variable assumed due to e.g. Greenland shark
## Checking by top 10 highest longevities
chord_data_filtered[order(-chord_data_filtered$Maximum.longevity..yrs.),][1:10, "Common.name"]
## Confirmed
## 0 mammals, 3 reptiles and 7 cartilaginous fish
## Plot without greenland shark for easier visibility
chord_data_filtered[chord_data_filtered$Common.name == "Greenland shark", ] ## row 1841
ggplot(subset(chord_data_filtered, Common.name != "Greenland shark"))+geom_jitter(size = 0.1, width = 0.1, aes(Class,Maximum.longevity..yrs.))+theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1), panel.grid = element_blank()) ## more readable

## longest living mammals
## Whales and humans, of course
mammal_data <- subset(chord_data_filtered, Class == "Mammalia")
mammal_data[order(-mammal_data$Maximum.longevity..yrs.),][1:10, "Common.name"]
ggplot(mammal_data)+geom_violin(size = 0.1, width = 0.1, aes(Class,Maximum.longevity..yrs.))+theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1), panel.grid = element_blank()) ## more readable
head(chord_data)



## Final plot

chord_data_filtered$avg_maturity <- (chord_data_filtered$Female.maturity..days. + chord_data_filtered$Male.maturity..days.) / 2

plot_data <- chord_data_filtered

plot_data <- plot_data %>%
  select(Class, Maximum.longevity..yrs., Growth.rate..1.days., avg_maturity) %>%
  pivot_longer(
    cols = c(Maximum.longevity..yrs., Growth.rate..1.days.,, avg_maturity),
    names_to = "Trait",
    values_to = "Value"
  )

chord_plot <- ggplot(plot_data)+
  geom_boxplot(aes(x = Class, y = Value, fill = Trait), position = position_dodge(width = 0.8), alpha = 0.8 )+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1), panel.grid = element_blank())

chord_plot
## Basic modelling

growth_long_mod <- lm(formula = Growth.rate..1.days. ~ Maximum.longevity..yrs., data = chord_data_filtered)
plot(growth_long_mod)
summary(growth_long_mod)

## To test, finding evidence of gene del in known human areas;
## Deletions in 20p12 are common, so search for those; genes include PROKR2, FERMT1, CM8 and bone morphogenic protein gene BMP2
## Try BMP1 first

## Species List
spp_list <- c("Mus musculus", "Homo sapiens", "Heterocephalus graber")


## GenAge Method 
## Opening csv of human genes from GenAge
genage_human <- read.csv("genage_human.csv", header = TRUE)
head(genage_human)
human_id <- genage_human$entrez.gene.id
## Same for model organisms
genage_model <- read.csv("genage_models.csv", header = TRUE)
head(genage_model)
model_id <- genage_human$entrez.gene.id


##NCBI BRUTE FORCE METHOD
## Finding aging related genes
set_entrez_key("1ea2e48010905dcfdbf2f68b509e6a9b2c09")
aging_genes <- entrez_search(db="gene",
                             term = "aging OR longevity OR senescence OR mTOR", retmax = 1000)

## Creating dataframe of aging related genes
gene_summ <- entrez_summary(db="gene", id=aging_genes$ids)
gene_info <- extract_from_esummary(gene_summ,
                                   c("uid","name","description","organism"))
gene_df <- data.frame(t(gene_info))
View(gene_df)
## alphabetising for manual comparison with GeneAge database
alph_gene_name <- sort(unlist(gene_df$name))
View(alph_gene_name)


