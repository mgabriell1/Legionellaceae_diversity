library(tidyverse)
library(MetBrewer)
library(tidymodels)
library(factoextra)
library(pals)
library(ape)
library(patchwork)
theme_set(theme_classic(base_size = 16))

legionomePangenome_KEGG_modules <- read_delim("Data/DRAM_noUniRef_all_KEGG_modules/legionomePangenome_KEGG_modules.tsv", 
                                              delim = "\t", escape_double = FALSE, 
                                              trim_ws = TRUE)
LegioID_legionomePangenome <- read_delim("Data/LegioID_legionomePangenome_genus.tsv", 
                                         delim = "\t", escape_double = FALSE, 
                                         trim_ws = TRUE)
KEGG_SignatureModules_list <- read_csv("Data/DRAM_noUniRef_all_KEGG_modules/KEGG_SignatureModules_list.csv", 
                                       comment = "#")

KEGGmodules_wide_all <- legionomePangenome_KEGG_modules %>% 
  filter(!(module %in% KEGG_SignatureModules_list$Module)) %>% 
  dplyr::group_by(module) %>% 
  mutate(sd_mod = sd(step_coverage), n_values = length(unique(as.character(step_coverage)))) %>% 
  #filter(sd_mod > 0, n_values > 1) %>% 
  mutate(genome = word(genome, 1, sep = "_")) %>% select(genome, module, step_coverage) %>% 
  pivot_wider(names_from = "module", values_from = "step_coverage")

legio_ids_isolates <- LegioID_legionomePangenome %>% filter(isolated) %>% pull(legio_id)
KEGGmodules_wide <- KEGGmodules_wide_all %>% filter(genome %in% legio_ids_isolates)

LegioID_legionomePangenome <- LegioID_legionomePangenome %>% 
  filter(isolated) %>% 
  select(legio_id, strain_cluster, gtdbtk.classification, species_info, genus_cluster_bestConcordance, genus_cluster_literature, genus_cluster) %>% 
  left_join(KEGGmodules_wide, by = c("legio_id" = "genome"))

KEGGmodules_pca <- LegioID_legionomePangenome %>% select(where(is.numeric)) %>% select(-c(genus_cluster_bestConcordance,genus_cluster_literature, genus_cluster))%>% 
  prcomp()

KEGGmodules_pca_eig <- KEGGmodules_pca %>%
  broom::tidy(matrix = "eigenvalues")

KEGGmodules_pca_res <- KEGGmodules_pca %>% broom::augment(LegioID_legionomePangenome)

## Clustering based on metabolic PCA
PCAcoords <- KEGGmodules_pca_res %>% select(legio_id, .fittedPC1,.fittedPC2)
NbClust::NbClust(PCAcoords[,2:3], method = "kmeans") # 2/3 clusters optimal depending on method: silhouette = 2 <- this results in a division on PC1, while with 3 also on PC2 which however explains less than PC1
metabolic_clusters <- kmeans(PCAcoords[,2:3], 2)
PCAcoords <- augment(metabolic_clusters, PCAcoords)

ggplot(PCAcoords, aes(.fittedPC1, .fittedPC2, col = .cluster)) +
  geom_point()

KEGGmodules_pca_res <- KEGGmodules_pca_res %>% left_join(PCAcoords)
#write_tsv(KEGGmodules_pca_res, "Data/DRAM_results_analysis/legionomePangenome_KEGG_modules_PCA_coords.tsv")

# KEGGmodules_pca_res %>% 
#   mutate(species_info = fct_relevel(factor(species_info), "Most clinically relevant", after = 0)) %>% 
#   ggplot(aes(.fittedPC1, .fittedPC2, col = species_info, shape = as.factor(genus_cluster_bestConcordance))) + 
#   geom_point(size = 1.5) + 
#   #geom_mark_hull(aes(.fittedPC1, .fittedPC2, col = as.factor(genus_cluster_bestConcordance)), concavity = 5) +
#   labs(x = paste0("PC1 (", round(KEGGmodules_pca_eig$percent[1],3)*100, "%)"), 
#        y = paste0("PC2 (", round(KEGGmodules_pca_eig$percent[2],3)*100, "%)"), 
#        col = "Genus cluster", shape = "Species") +
#   scale_color_manual(values = c("#a40000", "#ffcd12", "#007e2f","#16317d")) 
# #ggsave("/Users/gabriema/PostdocUMIK/Activities/Legionome/Plots/Metabolism/MetabolismKEGG_DRAMout_pca_isolated_species_info.pdf", dpi = 600, width = 10, height = 7)


KEGGmodules_pca_res_plot <- KEGGmodules_pca_res %>% 
  mutate(species_info = ifelse(species_info == "Named", "With scientific name", species_info),
         species_info = ifelse(species_info == "Confirmed pathogenic", "Clinically-associated", species_info),
         species_info = factor(species_info, levels = c("Most clinically relevant", "Clinically-associated", "With scientific name", "Not named"))) %>% 
  ggplot(aes(.fittedPC1, .fittedPC2, shape = species_info, col = as.factor(genus_cluster))) + 
  geom_point(size = 1.5) + 
  #geom_mark_hull(aes(.fittedPC1, .fittedPC2, col = as.factor(genus_cluster_bestConcordance)), concavity = 5) +
  labs(x = paste0("PC1 (", round(KEGGmodules_pca_eig$percent[1],3)*100, "%)"), 
       y = paste0("PC2 (", round(KEGGmodules_pca_eig$percent[2],3)*100, "%)"), 
       col = "Genus cluster", shape = "Species") +
  #scale_color_manual(values = c("#ff0029", "#377eb8bf", "#ff7f00","#fb8072","#80b1d3"))# + #These are the colors from the phylotree but don't work that well here
  scale_color_manual(values = met.brewer("Egypt", 5))
KEGGmodules_pca_res_plot
saveRDS(KEGGmodules_pca_res_plot, "/Users/gabriema/PostdocUMIK/Activities/Legionome/Plots/Metabolism/MetabolismKEGG_DRAMout_pca_isolated.RDS")
#ggsave("/Users/gabriema/PostdocUMIK/Activities/Legionome/Plots/Metabolism/MetabolismKEGG_DRAMout_pca_isolated.pdf", dpi = 600, width = 10, height = 7)

# KEGGmodules_pca_res %>% 
#   mutate(name = gsub("Tatlockia","Legionella",gsub("s__","",word(gtdbtk.classification, 7, sep = ";"))),
#          name = gsub("Legionella", "L.", name)) %>% 
#   ggplot(aes(.fittedPC1, .fittedPC2, shape = as.factor(genus_cluster_bestConcordance))) + geom_point(col = "grey") +
#   geom_point(aes(.fittedPC1, .fittedPC2, col = name), 
#          data = . %>% filter(species_info == "Most clinically relevant") ) + 
#   labs(x = paste0("PC1 (", round(KEGGmodules_pca_eig$percent[1],3)*100, "%)"), 
#        y = paste0("PC2 (", round(KEGGmodules_pca_eig$percent[2],3)*100, "%)"), 
#        col = "Species", shape = "Genus cluster") +
#   scale_color_met_d("Signac") #+ 
#   # geom_label(aes(label = name), vjust = 1, nudge_y = -0.2,
#   #            data = . %>% filter(str_detect(name, "sainth|long")))
# #ggsave("/Users/gabriema/PostdocUMIK/Activities/Legionome/Plots/Metabolism/MetabolismKEGG_DRAMout_pca_isolated_MostPathogenic.pdf", dpi = 600, width = 10, height = 7.2)
# ## -> L santheilensi is very close to L longbeacheae: also prevalent in soil?

KEGGmodules_pca_res %>%
  ggplot(aes(.fittedPC1, .fittedPC2, col = as.factor(genus_cluster_bestConcordance))) +
  geom_point(size = 1.5) +
  labs(x = paste0("PC1 (", round(KEGGmodules_pca_eig$percent[1],3)*100, "%)"),
       y = paste0("PC2 (", round(KEGGmodules_pca_eig$percent[2],3)*100, "%)"), col = "Genus cluster") +
  scale_color_manual(values = cols25(n = 22))

KEGGmodules_pca_res %>%
  ggplot(aes(.fittedPC1, .fittedPC2, col = as.factor(genus_cluster_literature))) +
  geom_point(size = 1.5) +
  labs(x = paste0("PC1 (", round(KEGGmodules_pca_eig$percent[1],3)*100, "%)"),
       y = paste0("PC2 (", round(KEGGmodules_pca_eig$percent[2],3)*100, "%)"), col = "Genus cluster") +
  scale_color_manual(values = cols25(n = 22))
# very messy. There seems to be an overall clustering, but not really that better compared to bestConcordance clustering

legioid_KEGG.df <- LegioID_legionomePangenome %>% #select(where(is.numeric)) %>% 
  select(legio_id, starts_with("M"))
legioid_KEGG.df_names <- legioid_KEGG.df$legio_id
legioid_KEGG.df <- as.data.frame(legioid_KEGG.df %>% select(starts_with("M")))
rownames(legioid_KEGG.df) <- legioid_KEGG.df_names
KEGGdist <- dist(legioid_KEGG.df)
vegan::adonis2(KEGGdist ~ as.factor(genus_cluster), LegioID_legionomePangenome)
vegan::anosim(KEGGdist, as.factor(LegioID_legionomePangenome$genus_cluster))

# vegan::adonis2(formula = KEGGdist ~ as.factor(genus_cluster), data = LegioID_legionomePangenome)
# Df SumOfSqs      R2      F Pr(>F)    
# as.factor(genus_cluster)   4    85.83 0.24631 8.9053  0.001 ***
#   Residual                 109   262.62 0.75369                  
# Total                    113   348.45 1.00000                  


## AAI data
aai_files <- list.files(paste0(data_dir,"legionome_ANI_AAI/AAI/"), pattern = ".txt", full.names = TRUE)
aai <- read_tsv(aai_files)
aai <- aai %>% mutate(AAI_value = as.numeric(gsub(">|%","",AAI_estimate)),
                      legioid_ref = word(target, 1, sep = "_"),
                      legioid_query = word(query, 1, sep = "_"))

KEGGdist_tbl <- tidy(KEGGdist)
colnames(KEGGdist_tbl) <-  c("legioid_ref", "legioid_query", "KEGGdist")
AAI_KEGGdist <- KEGGdist_tbl %>% left_join(aai)
AAI_KEGGdist %>% 
  ggplot(aes(KEGGdist, 100-AAI_value)) +
  geom_point()
# Positive correlations between KEGGdist and 100-ANI (as expected). But then?

cor.test(AAI_KEGGdist$KEGGdist, 100-AAI_KEGGdist$AAI_value, method = "spearman")


## Phylodist data
tree <- read.tree(paste0(data_dir,"/phylogeneticTrees/msa_softcore_protein_withOutgroup_Concatenator/iTOL_figure/Legionome_metadata_tree_rooted.treefile"))

phylodist <- as_tibble(cophenetic.phylo(tree)) %>% 
  mutate(query = row.names(cophenetic.phylo(tree))) %>% 
  pivot_longer(-query, values_to = "phylodist", names_to = "target") %>% 
  filter(!(query == "Coxiella_burnetii" | target == "Coxiella_burnetii")) %>% 
  rename(legioid_query = query, legioid_ref = target)
phylo_KEGGdist <- KEGGdist_tbl %>% left_join(phylodist)
phylo_KEGGdist %>% 
  ggplot(aes(KEGGdist, phylodist)) +
  geom_point()
# Positive correlations between KEGGdist and 100-ANI (as expected). But then?

cor.test(phylo_KEGGdist$KEGGdist, phylo_KEGGdist$phylodist, method = "spearman")


### HDBSCAN
KEGGdist_pca <- KEGGmodules_pca_res %>% select(c(`.fittedPC1`, `.fittedPC2`)) %>% dist()
KEGG_clust <- hdbscan(KEGGdist, minPts = 3)

cols <- c(NA, unname(cols25(max(KEGG_clust$cluster))))

MetabolismKEGG_DRAMout_pca_KEGGclustering <- KEGGmodules_pca_res %>%
  mutate(KEGG_clust = KEGG_clust$cluster) %>% 
  ggplot(aes(.fittedPC1, .fittedPC2, fill =  as.factor(KEGG_clust), shape = as.factor(genus_cluster))) +
  geom_point(size = 1.5) + #, data = . %>% filter(KEGG_clust != 0)
  #geom_point(size = 1.5, shape = 4, col = "grey", data = . %>% filter(KEGG_clust == 0)) +
  labs(x = paste0("PC1 (", round(KEGGmodules_pca_eig$percent[1],3)*100, "%)"),
       y = paste0("PC2 (", round(KEGGmodules_pca_eig$percent[2],3)*100, "%)"), 
       fill = "KEGG cluster", shape = "Genus cluster") +
  scale_fill_manual(values = cols, na.value = "white") +
  scale_shape_manual(values = c(21, 24, 22, 23, 25)) +
  guides(fill = guide_legend(override.aes=list(shape = 21)))
MetabolismKEGG_DRAMout_pca_KEGGclustering
ggsave("/Users/gabriema/PostdocUMIK/Activities/Legionome/Plots/Metabolism/MetabolismKEGG_DRAMout_pca_KEGGclustering.pdf", dpi = 600, width = 10, height = 7)

# KEGGmodules_pca_res %>%
#   mutate(KEGG_clust = KEGG_clust$cluster) %>% select(-c(starts_with("M"), starts_with(".fitted"))) %>% 
#   write_tsv("Data/DRAM_results_analysis/legionomePangenome_KEGG_modules_PCA_coords_KEGGclust.tsv")

KEGGmodules_pca_res %>% 
  mutate(KEGG_clust = KEGG_clust$cluster) %>% 
  mutate(species_cluster = word(strain_cluster, 1, 2, sep = "_")) %>% 
  group_by(species_cluster) %>% 
    summarise(n_genomes_species = n(), n_different_clusters = length(unique(KEGG_clust))) %>% view()

MetabolismKEGG_DRAMout_pca_KEGGclustering_info <- KEGGmodules_pca_res %>% 
  mutate(KEGG_clust = KEGG_clust$cluster) %>% 
  filter(KEGG_clust > 0) %>% 
  group_by(KEGG_clust, species_info) %>% 
  summarise(n = n()) %>% 
  mutate(species_info = ifelse(species_info == "Named", "With scientific name", species_info),
         species_info = ifelse(species_info == "Confirmed pathogenic", "Clinically-associated", species_info),
         species_info = factor(species_info, levels = c("Most clinically relevant", "Clinically-associated", "With scientific name", "Not named"))) %>% 
  ggplot(aes(as.factor(KEGG_clust), n, fill = species_info)) +
  geom_col() +
  scale_fill_manual(values = c("#dc322fe6", "#e66101e6", "#859900e6", "#268bd2e6")) +
  labs(x = "KEGG cluster", y = "Number of genomes [-]", fill = "Species")
MetabolismKEGG_DRAMout_pca_KEGGclustering_info

MetabolismKEGG_DRAMout_pca_KEGGclustering + #theme(legend.position = "bottom") + guides(fill = guide_legend(nrow=6,byrow=TRUE), shape = guide_legend(nrow=6,byrow=TRUE)) +
  MetabolismKEGG_DRAMout_pca_KEGGclustering_info + #theme(legend.position = "bottom") + guides(fill = guide_legend(nrow=4,byrow=TRUE)) +
  plot_annotation(tag_levels = 'a', tag_prefix = '(', tag_suffix = ')')
ggsave("/Users/gabriema/PostdocUMIK/Activities/Legionome/Plots/Metabolism/MetabolismKEGG_DRAMout_pca_KEGGclustering_species_info.pdf", dpi = 600, width = 14, height = 7)
