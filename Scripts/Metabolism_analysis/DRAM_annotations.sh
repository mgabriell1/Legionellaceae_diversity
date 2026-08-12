#!/bin/bash
#SBATCH -n 10                
#SBATCH --time 24:00:00                 
#SBATCH --mem-per-cpu=24000    
#SBATCH --array=1-164%64
#SBATCH -J DRAM_annotations
#SBATCH -o zout_%x.%j_%A_%a.%u.out
#SBATCH --mail-user=marco.gabrielli@eawag.ch
#SBATCH --mail-type=ALL


main_folder="/cluster/work/eawag/p07003/Data/legionomePangenome"
cd ${main_folder}

ls -d Legio*/ > ${SLURM_SUBMIT_DIR}/downloadedGenomes_List_$SLURM_ARRAY_TASK_ID
i="$(head -n $SLURM_ARRAY_TASK_ID ${SLURM_SUBMIT_DIR}/downloadedGenomes_List_$SLURM_ARRAY_TASK_ID | tail -n 1)"
rm ${SLURM_SUBMIT_DIR}/downloadedGenomes_List_$SLURM_ARRAY_TASK_ID

legioid=${i:0:10}
annotations_file=`ls ${i}/bakta_result/bakta_files/Legio*.faa | head -n 1`

module load seqkit

#seqkit replace -p "\s.+" ${annotations_file} ${i}/bakta_result/${legioid}.predictedProteins.noDescriptions.faa

source activate dram-env

DRAM.py annotate_genes -i ${annotations_file} -o ${i}/dram_annotations_noUniRef --verbose --threads 10 #--use_uniref

DRAM.py distill -i dram_annotations_noUniRef/annotations.tsv -o dram_annotations_noUniRef/distillate # --trna_path dram_annotations/trnas.tsv --rrna_path dram_annotations/rrnas.tsv

mv dram_annotations_noUniRef/distillate/product.tsv dram_annotations_noUniRef/distillate/${legioid}_product.tsv
mv dram_annotations_noUniRef/distillate/metabolism_summary.xlsx dram_annotations_noUniRef/distillate/${legioid}_metabolism_summary.xlsx