#!/bin/bash
#SBATCH -n 16                    
#SBATCH --time 12:00:00                 
#SBATCH --mem-per-cpu=16000    
#SBATCH --array=1-47%6
#SBATCH -J spades_assembly
#SBATCH -o zout_%x.%j_%a.%u.out
#SBATCH --mail-user=marco.gabrielli@eawag.ch
#SBATCH --mail-type=ALL

module load gcc/6.3.0
module load spades/3.15.4

master_folder=$WORK_LEGIONOME_EAWAG
i="$(head -n $SLURM_ARRAY_TASK_ID ${SLURM_SUBMIT_DIR}/WellcomeSangerInst_genomesList | tail -n 1)"

cd ${master_folder}/Data/downloadedGenomes/${i}/
mkdir assembly_isolate

sample=`ls reads/*R1.fastq.gz`
sample=${sample::-12}

spades.py --isolate -1 ${sample}.R1.trimmed.filtered.fastq.gz -2 ${sample}.R2.trimmed.filtered.fastq.gz \
	-o assembly_isolate

cp assembly_isolate/scaffolds.fasta .
mv scaffolds.fasta ${i::-1}.fna