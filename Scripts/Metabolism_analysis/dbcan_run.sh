#!/bin/bash
#SBATCH -n 4                
#SBATCH --time 12:00:00                 
#SBATCH --mem-per-cpu=8000    
#SBATCH --array=1-164%10
#SBATCH -J dbcan_run
#SBATCH -o zout_%x.%j_%A_%a.%u.out
#SBATCH --mail-user=marco.gabrielli@eawag.ch
#SBATCH --mail-type=ALL

main_folder="/cluster/work/eawag/p07003/Data/legionomePangenome"
cd ${main_folder}

ls -d Legio*/ > ${SLURM_SUBMIT_DIR}/downloadedGenomes_List_$SLURM_ARRAY_TASK_ID
i="$(head -n $SLURM_ARRAY_TASK_ID ${SLURM_SUBMIT_DIR}/downloadedGenomes_List_$SLURM_ARRAY_TASK_ID | tail -n 1)"
rm ${SLURM_SUBMIT_DIR}/downloadedGenomes_List_$SLURM_ARRAY_TASK_ID

source ~/Software/miniconda/bin/activate 
conda activate dbcan-env

cd ${i}
#mkdir dbcan_result
prots=`ls bakta_result/bakta_files/*.faa | grep -v "hyp"`
run_dbcan $prots protein --db_dir /cluster/project/eawag/p07003/Software/dbcan-db/db --out_dir dbcan_result
# Keep only proteins identified by at least 2 tools (https://bcb.unl.edu/dbCAN2/help.php)