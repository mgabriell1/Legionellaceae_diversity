#!/bin/bash
#SBATCH -n 8                    
#SBATCH --time 02:00:00                 
#SBATCH --mem-per-cpu=8000    
#SBATCH --array=45-47
#SBATCH -J fastp_trimming_univec_filtering
#SBATCH -o zout_%x.%j_%a.%u.out
#SBATCH --mail-user=marco.gabrielli@eawag.ch
#SBATCH --mail-type=ALL

module load bwa-mem2
module load samtools
module load bedtools2
module load fastp

master_folder=$WORK_LEGIONOME_EAWAG
i="$(head -n $SLURM_ARRAY_TASK_ID ${SLURM_SUBMIT_DIR}/WellcomeSangerInst_genomesList | tail -n 1)"

cd ${master_folder}/Data/downloadedGenomes/${i}/reads

# Take sample name
s=`ls *R1.fastq.gz`
sample=${s::-12}
mkdir -p ${sample}_QC_logs
echo "$sample started"

## Trim reads
fastp --in1 "$sample"_R1.fastq.gz --in2 "$sample"_R2.fastq.gz --thread 8 \
	--trim_poly_g --trim_poly_x --qualified_quality_phred 20 --length_required 20 --detect_adapter_for_pe \
	--out1 "$sample".R1.trimmed.fastq.gz --out2 "$sample".R2.trimmed.fastq.gz --unpaired1 "$sample".R1.unpaired.fastq.gz --unpaired2 "$sample".R2.unpaired.fastq.gz \
	-h ${sample}_QC_logs/"$sample".html &> ${sample}_QC_logs/"$sample"_fastp.log
echo "$sample trimmed"

## Map UniVec_Core and keep only not mapping ones
bwa-mem2 mem -t 8 /cluster/work/eawag/p07003/Data/utils/UniVec_Core "$sample".R1.trimmed.fastq.gz "$sample".R2.trimmed.fastq.gz > "$sample".UniVec_Core.sam
samtools view "$sample".UniVec_Core.sam -hbS -F2 -F2048 -@ 7 > "$sample".UniVec_Core.bam # view only reads with do not (F) properly map (2) or are supplementary alignment (2048)
samtools sort -n -@ 8 -o "$sample".sorted.UniVec_Core.bam "$sample".UniVec_Core.bam

bedtools bamtofastq -i "$sample".sorted.UniVec_Core.bam \
	-fq "$sample".R1.trimmed.filtered.fastq \
	-fq2 "$sample".R2.trimmed.filtered.fastq
	
gzip "$sample".R1.trimmed.filtered.fastq 
gzip "$sample".R2.trimmed.filtered.fastq
	
echo "$sample completed"
