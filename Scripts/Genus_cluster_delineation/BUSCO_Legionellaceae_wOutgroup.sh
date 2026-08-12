#!/bin/bash
#SBATCH -n 8                   
#SBATCH --time 48:00:00                 
#SBATCH --mem-per-cpu=8000    
#SBATCH -J BUSCO_Legionellaceae_wOutgroup
#SBATCH -o zout_%x.%j_%A_%a.%u.out
#SBATCH --mail-user=marco.gabrielli@eawag.ch
#SBATCH --mail-type=ALL

module load stack
module load eth_proxy

source ~/miniconda3/bin/activate 
conda activate busco-env

cd /cluster/work/eawag/p07003/Data/legionomePangenome

busco -i proteinFolder_legionome_withOutgroup/ -o Legionome_wOutgroup_BUSCO_autoLineage -m prot --auto-lineage-prok -c 8 

busco -i proteinFolder_legionome_withOutgroup/ -l legionellales_odb12 -o Legionome_wOutgroup_BUSCO_Legionellales_odb12 -m prot -c 8 