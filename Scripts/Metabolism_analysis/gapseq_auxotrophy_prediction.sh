#!/bin/bash
#SBATCH -n 1                
#SBATCH --time 24:00:00                 
#SBATCH --mem-per-cpu=8000    
#SBATCH -J gapseq_auxotrophies
#SBATCH -o zout_%x.%j_%A_%a.%u.out
#SBATCH --mail-user=marco.gabrielli@eawag.ch
#SBATCH --mail-type=ALL


main_folder="/cluster/work/eawag/p07003/Data/legionomePangenome"
cd ${main_folder}

source ~/miniconda3/bin/activate 
conda activate gapseq-env

for i in Legio*/; do
	mod=`ls $i/gapseq_model/*RDS | grep -v "draft" | grep -v "rxn"`

	echo $mod
	Rscript /cluster/work/eawag/p07003/Scripts/gapseq_auxotrophy_prediction.R $mod
done