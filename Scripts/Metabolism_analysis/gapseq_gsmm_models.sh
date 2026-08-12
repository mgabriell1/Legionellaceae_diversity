#!/bin/bash
#SBATCH -n 1                    
#SBATCH --time 12:00:00                 
#SBATCH --mem-per-cpu=16000    
#SBATCH --array=1-164%10
#SBATCH -J gapseq_modelling
#SBATCH -o zout_%x.%j_%A_%a.%u.out
#SBATCH --mail-user=marco.gabrielli@eawag.ch
#SBATCH --mail-type=ALL

main_folder="/cluster/work/eawag/p07003/Data/legionomePangenome"
cd ${main_folder}

ls -d Legio*/ > ${SLURM_SUBMIT_DIR}/downloadedGenomes_List_$SLURM_ARRAY_TASK_ID
i="$(head -n $SLURM_ARRAY_TASK_ID ${SLURM_SUBMIT_DIR}/downloadedGenomes_List_$SLURM_ARRAY_TASK_ID | tail -n 1)"
rm ${SLURM_SUBMIT_DIR}/downloadedGenomes_List_$SLURM_ARRAY_TASK_ID

GAPSEQ="/cluster/project/eawag/p07003/Software/gapseq/gapseq"

module load eth-proxy

source ~/miniconda3/bin/activate 
conda activate gapseq-env

prot_files=`ls ${i}/bakta_result/bakta_files/*.faa`
prot_files=`echo $prot_files | awk -F" " {'print $1'}`

mkdir ${i}/gapseq_model
cp $prot_files ${i}/gapseq_model
cd ${i}/gapseq_model

dt=$(date '+%d/%m/%Y %H:%M');
echo "Started modelling $prot_files at $dt"

$GAPSEQ doall *.faa 

dt=$(date '+%d/%m/%Y %H:%M');
echo "Modelling ended at $dt"
