#!/bin/bash
#SBATCH -n 4                    
#SBATCH --time 12:00:00                 
#SBATCH --mem-per-cpu=8000    
#SBATCH -J fastaai_legionome
#SBATCH -o zout_%x.%j_%A_%a.%u.out
#SBATCH --mail-user=marco.gabrielli@eawag.ch
#SBATCH --mail-type=ALL

source ~/miniconda3/bin/activate 
conda activate fastaai-env

cd /cluster/work/eawag/p07003/Data/legionomePangenome

fastaai build_db --proteins proteinFolder_legionome/faa_files/ --threads 4 --verbose --output fastaai_legionome --database legionome_proteins.db --compress

fastaai db_query --query fastaai_legionome/database/legionome_proteins.db --target fastaai_legionome/database/legionome_proteins.db --threads 4 --verbose --output fastaai_legionome --do_stdev --output_style tsv