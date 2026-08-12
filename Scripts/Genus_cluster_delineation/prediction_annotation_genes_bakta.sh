#!/bin/bash
#SBATCH -n 8                    
#SBATCH --time 01:00:00                 
#SBATCH --mem-per-cpu=8000    
#SBATCH --array=1-236%64
#SBATCH -J prediction_annotation_genes_bakta
#SBATCH -o zout_%x.%j_%A_%a.%u.out
#SBATCH --mail-user=marco.gabrielli@eawag.ch
#SBATCH --mail-type=ALL

main_folder="/cluster/work/eawag/p07003/Data/legionomePangenome"
cd ${main_folder}

ls -d Legio*/ > ${SLURM_SUBMIT_DIR}/downloadedGenomes_List_$SLURM_ARRAY_TASK_ID
i="$(head -n $SLURM_ARRAY_TASK_ID ${SLURM_SUBMIT_DIR}/downloadedGenomes_List_$SLURM_ARRAY_TASK_ID | tail -n 1)"
rm ${SLURM_SUBMIT_DIR}/downloadedGenomes_List_$SLURM_ARRAY_TASK_ID

echo "Annotations of genes of genome $i"

source activate bakta-env
bakta --db $PROJECT_LEGIONOME_EAWAG/Software/bakta-db/db --verbose \
	--output ${i}/bakta_result/bakta_files --threads 8 ${i}/*.fna
conda deactivate

