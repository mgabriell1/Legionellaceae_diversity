#!/bin/bash
#SBATCH -n 4                
#SBATCH --time 24:00:00                 
#SBATCH --mem-per-cpu=8000    
#SBATCH -J platon_plasmids
#SBATCH --array=1-164%10
#SBATCH -o zout_%x.%j_%A_%a.%u.out
#SBATCH --mail-user=marco.gabrielli@eawag.ch
#SBATCH --mail-type=ALL


main_folder="/cluster/work/eawag/p07003/Data/legionomePangenome"
cd ${main_folder}

source ~/Software/miniconda/bin/activate 
conda activate platon-env

ls -d Legio*/ > ${SLURM_SUBMIT_DIR}/downloadedGenomes_List_$SLURM_ARRAY_TASK_ID
i="$(head -n $SLURM_ARRAY_TASK_ID ${SLURM_SUBMIT_DIR}/downloadedGenomes_List_$SLURM_ARRAY_TASK_ID | tail -n 1)"
rm ${SLURM_SUBMIT_DIR}/downloadedGenomes_List_$SLURM_ARRAY_TASK_ID

#mkdir ${i}/platon_output

platon --db /cluster/project/eawag/p07003/Software/platon-db/db -t 4 -o ${i}/platon_result --verbose ${i}/bakta_result/bakta_files/*.fna
