metadata <- read_tsv(paste0(data_dir,"LegioID_legionomePangenome_genus.tsv"))
dat <- read_tsv("/Users/gabriema/PostdocUMIK/Activities/Legionome/Data/downloadedGenomes_checkm2.quality_report.tsv")

dat_ref <- dat %>% mutate(legio_id = word(Name, 1, sep = "_")) %>% 
  select(legio_id, GC_Content) %>% 
  dplyr::rename(checkm2.GC_Content = GC_Content)

metadata <- metadata %>% left_join(dat_ref)
#write_tsv(metadata, paste0(data_dir,"LegioID_legionomePangenome_genus.tsv"))

metadata %>% 
  group_by(genus_cluster) %>% 
  mutate(n_genomes = n()) %>% 
  filter(n_genomes > 3) %>% 
  ggplot(aes(as.factor(genus_cluster), checkm2.GC_Content)) +
  geom_boxplot()


metadata %>% 
  group_by(genus_cluster) %>% 
  mutate(n_genomes = n()) %>% 
  filter(n_genomes > 3) %>% 
  ungroup() %>% 
  rstatix::anova_test(checkm2.GC_Content ~ as.factor(genus_cluster))

metadata %>% 
  group_by(genus_cluster) %>% 
  mutate(n_genomes = n()) %>% 
  filter(n_genomes > 3) %>% 
  ungroup() %>% 
  rstatix::tukey_hsd(checkm2.GC_Content ~ as.factor(genus_cluster))
# Genus 1 different from 6, 5 and 13