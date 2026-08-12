#!/bin/bash
#SBATCH -n 8                    
#SBATCH --time 01:00:00                 
#SBATCH --mem-per-cpu=8000    
#SBATCH --array=1-4939%128
#SBATCH -J downloadedGenomes_QC_seqkit_checkm2_gunc_gtdbtk
#SBATCH -o zout_%x.%j_%A_%a.%u.out
#SBATCH --mail-user=marco.gabrielli@eawag.ch
#SBATCH --mail-type=ALL

main_folder="/cluster/work/eawag/p07003/Data/downloadedGenomes"
cd ${main_folder}

ls -d */ > ${SLURM_SUBMIT_DIR}/downloadedGenomes_List_$SLURM_ARRAY_TASK_ID
i="$(head -n $SLURM_ARRAY_TASK_ID ${SLURM_SUBMIT_DIR}/downloadedGenomes_List_$SLURM_ARRAY_TASK_ID | tail -n 1)"
rm ${SLURM_SUBMIT_DIR}/downloadedGenomes_List_$SLURM_ARRAY_TASK_ID

echo "Quality control of genome $i"


### Remove too-short contigs (i.e., below 1kbp)
genome=`ls ${i}*.fna`

if test -f "${genome}.gz"; then
	echo "Original genome already present"
else
	echo "Saving original ${genome} genome to gzip and keeping only contigs above 1kbp"
	gzip < $genome > $genome.gz

	module load seqkit
	seqkit seq ${genome}.gz -m 1000 -o ${genome}
fi

### CheckM2 QC

if test -f "${i}/checkm2_result/quality_report.tsv"; then
	echo "CheckM2 results already exist. Skipped."
else
	echo "++++++"
	echo "CheckM2"
	source activate checkm2-env
	mkdir ${i}/checkm2_result
	checkm2 predict --threads 8 --input ${i}/*.fna --output-directory ${i}/checkm2_result --database_path "/cluster/project/eawag/p07003/Software/checkm2-db/CheckM2_database/uniref100.KO.1.dmnd"
	conda deactivate
fi

### GUNC QC

if test -f "${i}/gunc_result/GUNC.progenomes_2.1.maxCSS_level.tsv"; then
	echo "GUNC results already exist. Skipped."
else
	echo "++++++"
	echo "GUNC"
	source activate gunc-env
	mkdir ${i}/gunc_result
	gunc run --input_fasta ${i}/*.fna --db_file "/cluster/project/eawag/p07003/Software/gunc-db/gunc_db_progenomes2.1.dmnd" --threads 8 --out_dir ${i}/gunc_result
	conda deactivate
fi

## GTDB-Tk QC

if test -f "${i}/gtdbtk_result/classify/classify/gtdbtk.bac120.summary.tsv "; then
	echo "GTDB-Tk results already exist. Skipped."
else
	echo "++++++"
	echo "GTDB-Tk"
	mkdir ${i}/gtdbtk_result

	source activate gtdbtk-env
	gtdbtk classify_wf --genome_dir ${i} --mash_db "/cluster/project/eawag/p07003/Software/gtdbtk-db/mashdb" --cpus 8 --pplacer_cpus 8 --write_single_copy_genes --keep_intermediates --out_dir ${i}/gtdbtk_result
	conda deactivate
fi