library(sybil)
library(readr)
library(dplyr)

args <- commandArgs(trailingOnly = TRUE)

model_file <- args[1]
#output_folder <- gsub("gapseq_model/.*$","gapseq_model/", args[1])
legio_id <- paste0(gsub(".RDS","",model_file)) # gsub("_.*$", "", gsub("^.*/Legio", "Legio", args[1]))

comps <- read_csv("/cluster/work/eawag/p07003/Scripts/GapSeq_auxotrophy_compounds.csv")
mod <- readRDS(model_file)

opt <- optimizeProb(mod)
mod_out <- mod_obj(opt)

gapseq_preds <- tibble(legio_id = legio_id, comp = "all", obj_out = mod_out)

for (i in 1:nrow(comps)){
  comp_name <- comps$Compound_name[i]
  comp_ID <- comps$Compound_ID[i]
  print(comp_name)
  
  mod_aux <- mod
  lowbnd(mod_aux)[react_id(mod_aux) == paste0("EX_", comp_ID, "_e0")] <- 0
  opt_aux <- optimizeProb(mod_aux)
  mod_aux_out <- mod_obj(opt_aux)
  
  gapseq_preds <- gapseq_preds %>% bind_rows(tibble(legio_id = legio_id, comp = comp_name, obj_out = mod_aux_out))
  
  if (comp_name == "L-Cysteine"){
    mod_aux_so4 <- mod_aux
    lowbnd(mod_aux_so4)[react_id(mod_aux_so4) == paste0("EX_cpd00048_e0")] <- 0
    opt_aux_s04 <- optimizeProb(mod_aux_so4)
    mod_aux_so4_out <- mod_obj(opt_aux_s04)
    gapseq_preds <- gapseq_preds %>% bind_rows(tibble(legio_id = legio_id, comp = paste0(comp_name, " - No SO4"), obj_out = mod_aux_so4_out))
    
    mod_aux_h2s <- mod_aux
    lowbnd(mod_aux_h2s)[react_id(mod_aux_h2s) == paste0("EX_cpd00239_e0")] <- 0
    opt_aux_h2s <- optimizeProb(mod_aux_h2s)
    mod_aux_h2s_out <- mod_obj(opt_aux_h2s)
    gapseq_preds <- gapseq_preds %>% bind_rows(tibble(legio_id = legio_id, comp = paste0(comp_name, " - No H2S"), obj_out = mod_aux_h2s_out))
  }
}

write_tsv(gapseq_preds, paste0(gsub(".RDS","",model_file),"_gapseq_auxotrophies.tsv"))