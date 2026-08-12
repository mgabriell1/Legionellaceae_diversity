#!/bin/bash
#SBATCH -n 12                    
#SBATCH --time 01:00:00                 
#SBATCH --mem-per-cpu=8000    
#SBATCH --array=1-109
#SBATCH -J secondaryClustering_skani
#SBATCH -o zout_%x.%j_%A_%a.%u.out
#SBATCH --mail-user=marco.gabrielli@eawag.ch
#SBATCH --mail-type=ALL

main_folder="/cluster/work/eawag/p07003/Data/filteredGenomes_QC_manRef/dRep_dereplication/secondaryClustering_skani"
cd $main_folder

ls -d */ > ${SLURM_SUBMIT_DIR}/primaryCluster_MASH_List_$SLURM_ARRAY_TASK_ID
i="$(head -n $SLURM_ARRAY_TASK_ID ${SLURM_SUBMIT_DIR}/primaryCluster_MASH_List_$SLURM_ARRAY_TASK_ID | tail -n 1)"
rm ${SLURM_SUBMIT_DIR}/primaryCluster_MASH_List_$SLURM_ARRAY_TASK_ID

echo "Secondary clustering of MASH cluster $i"

##
source activate skani-env

skani triangle ${i}/*.fna -t 12 --ci --sparse -o secondaryClustering_skani_${i::-1}.tsv

