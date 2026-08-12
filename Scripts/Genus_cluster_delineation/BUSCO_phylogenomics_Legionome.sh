#!/bin/bash
#SBATCH -n 10                   
#SBATCH --time 24:00:00                 
#SBATCH --mem-per-cpu=8000    
#SBATCH -J BUSCO_phylogenomics_Legionome
#SBATCH -o zout_%x.%j_%A_%a.%u.out
#SBATCH --mail-user=marco.gabrielli@eawag.ch
#SBATCH --mail-type=ALL

source ~/miniconda3/bin/activate 
conda activate buscophylogenomics-env

cd /cluster/work/eawag/p07003/Data/legionomePangenome

BUSCO_phylogenomics.py -i Legionome_wOutgroup_BUSCO_Legionellales_odb12 -o BUSCO_phylogenomics_Legionellales_odb12_Legionome_interactive -t 10 -psc 95 --gene_tree_program iqtree