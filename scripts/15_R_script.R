################################################################################
# List of packages to install
packagesList <- c("tidyverse", "parallel", "vegan", "directlabels", "networkD3", 
                                   "ggforce", "VennDiagram")

# The following libraries must be installed in Linux before the installation of the R packages:
# libfontconfig1-dev libharfbuzz-dev libfribidi-dev

# Check if packages are installed and install them in case they aren't and load them
for (pkg in packagesList) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
    library(pkg, character.only = TRUE)
  }
}

################################################################################

# User defined functions

# This function get the bin name of the contig 
getBin <- function(contig){
  bin <- paste(strsplit(x = contig, split = "_")[[1]][1:2], collapse = "_")
  return(bin)
}

# This function produce the LCA taxonomic annotation of a bin
annotateBin <- function(resDF){
  
  m <-  dim(resDF)[1]
  n <- dim(resDF)[2]
  taxaList <- names(resDF)[2:n]
  
  if (m == 1) {
    
    defTax <- resDF
    
  } else {
    
    defTax <- defDF <- data.frame(matrix(nrow = 1, ncol = n))
    names(defTax) <- names(resDF)
    defTax[1, 1] <- resDF[1, 1]
    
    for(tax in rev(taxaList)){
      
      comp <- table(resDF[, tax], useNA = 'always') / m
      
      if(any(comp[!is.na(names(comp))] >= 0.6) == TRUE){
        
        deft <- names(comp)[comp >= 0.6]
        index <- which(resDF == deft, arr.ind = TRUE)[1, ]
        DTV <- resDF[index[1], 2:index[2]] %>% slice(1)
        defTax[names(DTV)] <- DTV
        break
        
      } 
    }
  }
  return(defTax)
}

# This function obtains the taxonomic annotation of all bins in the table
annotateTable <- function(DF, type){
  
  if (type == "virus") {
    taxaList <- c("Superkingdom", "Realm", "Kingdom", "Phylum", "Class", "Order", "Family", "Genus")
  } else if (type == "host") {
    taxaList <- c("Domain", "Phylum", "Class", "Order", "Family", "Genus")
  }
  
  D <- DF %>%
    select(Bin, all_of(taxaList)) %>%
    drop_na(Bin) %>%
    rowwise() %>%
    filter(!if_all(taxaList, ~is.na(.)))
  
  BinsList <- unique(D[, "Bin"] %>% pull())
  n_Bins <- length(BinsList)
  
  # Preallocate defDF with the known number of rows
  defDF <- data.frame(matrix(ncol = length(taxaList) + 1, 
                             nrow = n_Bins))
  names(defDF) <- names(D) 
  
  # Get the number of cores
  no_cores <- detectCores() - 1
  
  # Use mclapply to apply the function in parallel
  defDF <- mclapply(seq_len(n_Bins), function(i) {
    c <- BinsList[i]
    resDF <- D %>% filter(pick(Bin) == c)
    defTax <- annotateBin(resDF = resDF)
    df <- data.frame(defTax)
    return(df)
  }, mc.cores = no_cores)
  
  # Combine the results
  defDF <- do.call(rbind, defDF)
  
  
  return(defDF)
  
}

################################################################################
# Tables directory
d <- "path/to/finalTables/"
################################################################################

# Plasmids DF
plasmids <- read_tsv(file = paste0(d, "totalBinnedContigs_plasmid_summary.tsv"))
# No plasmids to delete

# contigs DFs
AJ_female <- read_tsv(file = paste0(d, "A_japonicus_female_coverage.tsv"), 
                      col_names = c("Contig", "Mean", "Read_Count", "Length", "RPKM", "TPM"), 
                      skip = 1) %>%
  mutate(Sample = "female") %>%
  rowwise() %>%
  mutate(Bin = if_else(grepl(x = Contig, pattern = "__"), 
                       getBin(Contig), 
                       Contig)) %>%
  filter(grepl(pattern = "_female_", x = Bin) | grepl(pattern = "vRhyme", x = Bin))
  

AJ_male <- read_tsv(file = paste0(d, "A_japonicus_male_coverage.tsv"), 
                    col_names = c("Contig", "Mean", "Read_Count", "Length", "RPKM", "TPM"), 
                    skip = 1) %>%
  mutate(Sample = "male") %>%
  rowwise() %>%
  mutate(Bin = if_else(grepl(x = Contig, pattern = "__"), 
                       getBin(Contig), 
                       Contig))  %>%
  filter(grepl(pattern = "_male_", x = Bin) | grepl(pattern = "vRhyme", x = Bin))

# Total number of contigs
# Female 
AJ_female %>% filter(! RPKM == 0) %>% pull(Contig) %>% unique() %>% length() #1260
# Male
AJ_male %>% filter(! RPKM == 0) %>% pull(Contig) %>% unique() %>% length() #1175

# Bins DFs
AJ_female_bins <- AJ_female %>% 
  group_by(Bin, Sample) %>% 
  summarise(RPKM = sum(RPKM), Read_Count = sum(Read_Count))

AJ_male_bins <- AJ_male %>% 
  group_by(Bin, Sample) %>% 
  summarise(RPKM = sum(RPKM), Read_Count = sum(Read_Count))

# Total number of bins
# Female 
AJ_female_bins %>% filter(! RPKM == 0) %>% pull(Bin) %>% unique() %>% length() #113
# Male
AJ_male_bins %>% filter(! RPKM == 0) %>% pull(Bin) %>% unique() %>% length() #101

# Taxonomy
# ICTV taxonomy
ictv_tax <- c("Superkingdom", "Realm", "Kingdom", "Phylum", "Class", "Order", "Family", "Genus")

# Contigs taxonomy DF
taxonomy <-  read_tsv(file = paste0(d, "totalBinnedContigs_virus_summary.tsv")) %>%
  select(seq_name, taxonomy)  %>%
  rowwise() %>%
  separate(taxonomy, 
           sep = ";", 
           into = ictv_tax) %>%
  rowwise() %>%
  mutate(Bin = if_else(grepl(x = seq_name, pattern = "__"), 
                       getBin(seq_name), 
                       seq_name)) %>%
  select(-seq_name)

# Bins taxonomy DF
bin_tax <- annotateTable(DF = taxonomy, type = "virus")

# Change names
names(bin_tax) <- c("Bin", "vir_Superkingdom", "vir_Realm", "vir_Kingdom", 
                    "vir_Phylum", "vir_Class", "vir_Order", "vir_Family", 
                    "vir-Genus")

# Host 
# GTDB Prokaryotes taxonomy
gtdb_tax <- c("Domain", "Phylum", "Class", "Order", "Family", "Genus")

# Hosts of the contigs DF
hosts <- read_csv(file = paste0(d, "Host_prediction_to_genus_m80.csv"), 
                  col_names = c("Virus", "AAI", "Host", "Confidence_score", "Methods"), 
                  skip = 1) %>%
  select(Virus, Host)  %>%
  rowwise() %>%
  separate(Host, 
           sep = ";", 
           into = gtdb_tax) %>%
  rowwise() %>%
  mutate(across(Domain:Genus, ~str_split(., "__", simplify = TRUE)[, 2])) %>%
  mutate(Bin = if_else(grepl(x = Virus, pattern = "__"), 
                       getBin(Virus), 
                       Virus)) %>%
  select(-Virus)

# Hosts of the bins DF
bin_host <-  annotateTable(DF = hosts, type = "host")

# Change names
names(bin_host) <- c("Bin", "host_Domain", "host_Phylum", "host_Class",  "host_Order", "host_Family", "host_Genus")

# Create a DF with all the annotations
bins <- rbind(AJ_female_bins, AJ_male_bins) %>%
  left_join(bin_tax) %>%
  left_join(bin_host)

# Venn plot Bins
female <- bins %>% filter(Sample == "female") %>% pull(Bin) %>% sort()
male <- bins %>% filter(Sample == "male") %>% pull(Bin) %>% sort()  

# Plot
venn.diagram(
  x = list(female, male), 
  category.names = c("Female", "Male"),
  filename = paste0(d, 'venn_diagram.png'),
  output = TRUE,
  
  # Output features
  imagetype = "png",
  height = 600, 
  width = 600, 
  resolution = 600,
  compression = "lzw",
  
  # Circles
  scaled = TRUE,
  lwd = 0.5,
  col = "black",
  fill = RColorBrewer::brewer.pal(3, "Pastel1")[1:2],
  
  # Numbers
  cex = .6,
  fontface = "bold",
  fontfamily = "sans",
  
  # Set names
  cat.cex = 0.6,
  cat.fontface = "bold",
  cat.default.pos = "outer",
  cat.pos = c(-27, 27),
  cat.dist = c(0.055, 0.055),
  cat.fontfamily = "sans"
)

# sankey plot with viral taxonomy and host taxonomy
#Female DF
bins_female_sankey <- bins %>% 
  filter(Sample == "female") %>% 
  select(-Sample) %>% 
  group_by(vir_Class, host_Class) %>% 
  summarise(RPKM = sum(RPKM)) %>%
  arrange(desc(RPKM)) %>%
  rowwise() %>%
  mutate(vir_Class = if_else(is.na(vir_Class), "Unkown Viral Class", vir_Class)) %>%
  mutate(host_Class = if_else(is.na(host_Class), "Unkown Host Class", host_Class)) %>% 
  mutate(Sex = "Female")

# Male DF
bins_male_sankey <- bins %>% 
  filter(Sample == "male") %>% 
  select(-Sample) %>% 
  group_by(vir_Class, host_Class) %>% 
  summarise(RPKM = sum(RPKM)) %>%
  arrange(desc(RPKM)) %>%
  rowwise() %>%
  mutate(vir_Class = if_else(is.na(vir_Class), "Unkown Viral Class", vir_Class)) %>%
  mutate(host_Class = if_else(is.na(host_Class), "Unkown Host Class", host_Class)) %>%
  mutate(Sex = "Male")

# Get the final DF
data <- rbind(female, male)

data <- gather_set_data(data, c(1, 2))

#  Plot it
jpeg(paste0(d, "tax_host_SankeyPlot.jpg"), height = 11000, width = 15000, 
     res = 600, quality = 100)

ggplot(data, aes(x, id = id, split = y, value = RPKM)) +
  scale_x_discrete(labels = c("Viral Class", "Host Class"), limits = factor(c(1, 2))) +
  geom_parallel_sets(aes(fill = Sex), alpha = 0.3, axis.width = 0.1) +
  geom_parallel_sets_axes(axis.width = 0.1) +
  geom_parallel_sets_labels(colour = 'black', angle = 0, nudge_x = 0.08, hjust = 0, size = 6) +
  theme_void() + 
  theme(legend.position = "top",
        legend.key.size = unit(1, 'cm'),
        legend.key.height = unit(1, 'cm'),
        legend.key.width = unit(1, 'cm'),
        #text = element_text(size = 24), 
        legend.text = element_text(face = "bold", size = 14),
        legend.title =  element_text(face = "bold", size = 16), 
        axis.text.x = element_text(angle = 0, hjust = 0.5, size = 16, face = "bold")) 

dev.off()

# Diversity analysis
# DF
bins_div <- bins %>% 
  select(Bin, Sample, Read_Count) %>%
  pivot_wider(names_from = Bin, values_from = Read_Count) %>%
  arrange(Sample) %>%
  column_to_rownames("Sample") %>%
  mutate(across(everything(), ~replace_na(., 0)))

# Alpha diversity
shannon <- diversity(bins_div, index = "shannon")
simpson <- diversity(bins_div, index = "simpson")
chao1 <-  estimateR(bins_div)[2, ]
AdIVdf <- data.frame(Shannon = shannon, Simpson = simpson, Chao1 = chao1)
AdIVdf

# Rarefaction analysis
S <- specnumber(bins_div)
raremax <- min(rowSums(bins_div))
Srare <- rarefy(bins_div, raremax)
rare_tab <- rarecurve(bins_div, step = 10, sample = raremax,
                      xlab = "Reads", ylab = "Bins", tidy = TRUE)

# Rarefaction curves plot
jpeg(paste0(d, "rarefactionCurves.jpg"), height = 4000, width = 7000, 
     res = 600, quality = 100)

ggplot(rare_tab, aes(x = Sample, y = Species)) + 
  geom_line(aes(color = Site)) +  
  geom_dl(aes(label = Site),
          method = list(dl.trans(x = x + 0.2),
                        "last.points",
                        cex = 0.8,
                        color = "black")) +
  ylab("Bins") +
  xlab("Reads") +
  theme_minimal() +
  theme(legend.position = "none",
        axis.title.y = element_text(face = "bold", size = 14), 
        axis.title.x = element_text(face = "bold", size = 14))

dev.off()

# Protein annotation
prots <- read_tsv(file = paste0(d, "annotations.tsv"))
KOs_tab <- read_tsv(file = paste0(d, "metabolism_vigo.tsv"))
AJ_female_anno <- AJ_female %>% select(Contig, RPKM, Sample)
AJ_male_anno <-  AJ_male %>% select(Contig, RPKM, Sample)
AJ_anno <- rbind(AJ_female_anno, AJ_male_anno)

# KEGG Orthologies
KOs <- prots %>%
  filter(!is.na(ko_id)) %>%
  select(scaffold, ko_id, kegg_hit) %>%
  left_join(AJ_anno, by = c("scaffold" = "Contig")) %>%
  left_join(KOs_tab, by = c("ko_id" = "KO")) %>%
  filter(!is.na(Pathway))

# DF for Sankey plot
KOs_sankey <- KOs %>%
  select(Type_2, Type_1, Pathway, ko_id, Sample, RPKM) %>% 
  filter(RPKM != 0) %>%
  group_by(Type_2, Type_1, Pathway, ko_id) %>%
  summarise(RPKM = sum(RPKM)) %>%
  mutate(fill = Type_2) %>%
  gather_set_data(c(1, 2, 3, 4)) %>%
  mutate(y = fct_relevel(y))

# Plot it
jpeg(paste0(d, "metaSankey.jpg"), height = 11000, width = 15000, 
     res = 600, quality = 100)

ggplot(KOs_sankey, aes(x, id = id, split = y, value = RPKM)) +
  scale_x_discrete(labels = c("Category", "Subcategory", "Pathway", "KO"), limits = factor(c(1, 2, 3, 4))) +
  geom_parallel_sets(aes(fill = fill), alpha = 0.3, axis.width = 0.1) +
  geom_parallel_sets_axes(axis.width = 0.1) +
  geom_parallel_sets_labels(colour = 'black', angle = 0, nudge_x = 0.08, hjust = 0, size = 6) +
  theme_void() + 
  theme(legend.position = "none",
        # legend.key.size = unit(1, 'cm'),
        # legend.key.height = unit(1, 'cm'),
        # legend.key.width = unit(1, 'cm'),
        text = element_text(face = "bold", size = 10), 
        # legend.text = element_text(face = "bold", size = 14),
        # legend.title =  element_text(face = "bold", size = 16), 
        axis.text.x = element_text(angle = 0, hjust = 0.5, size = 40, face = "bold")) 
dev.off()

# Bins Quality
# CheckV DF
checkVDF <- read_tsv(file = paste0(d, "quality_summary.tsv"))

# Quality results
checkVDF %>% select(checkv_quality) %>% 
  group_by(checkv_quality) %>% 
  summarise(percentage = 100 * n()/nrow(checkVDF))

# Lysis VS Lisogeny
checkVDF %>% select(provirus) %>% 
  group_by(provirus) %>% 
  summarise(percentage = 100 * n()/nrow(checkVDF))
