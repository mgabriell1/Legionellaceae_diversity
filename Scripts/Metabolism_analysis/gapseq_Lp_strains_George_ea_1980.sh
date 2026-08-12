#!/bin/bash
#SBATCH -n 1                    
#SBATCH --time 12:00:00                 
#SBATCH --mem-per-cpu=16000    
#SBATCH --array=1-4
#SBATCH -J gapseq_modelling
#SBATCH -o zout_%x.%j_%A_%a.%u.out
#SBATCH --mail-user=marco.gabrielli@eawag.ch
#SBATCH --mail-type=ALL

module load eth-proxy

source ~/miniconda3/bin/activate 
conda activate gapseq-env

main_folder="/cluster/work/eawag/p07003/Data/Lp_strains_auxotrphy_George_ea_1980"
cd ${main_folder}

ls GCF*faa > ${SLURM_SUBMIT_DIR}/downloadedGenomes_List_$SLURM_ARRAY_TASK_ID
i="$(head -n $SLURM_ARRAY_TASK_ID ${SLURM_SUBMIT_DIR}/downloadedGenomes_List_$SLURM_ARRAY_TASK_ID | tail -n 1)"
rm ${SLURM_SUBMIT_DIR}/downloadedGenomes_List_$SLURM_ARRAY_TASK_ID

GAPSEQ="/cluster/project/eawag/p07003/Software/gapseq/gapseq"


dt=$(date '+%d/%m/%Y %H:%M');
echo "Started modelling $prot_files at $dt"

#$GAPSEQ doall $i

dt=$(date '+%d/%m/%Y %H:%M');
echo "Modelling ended at $dt"

mod=`ls ${i::-3}RDS` 

echo $mod
Rscript gapseq_Lp_strains_George_ea_1980_auxopred.R $mod