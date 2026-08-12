#!/bin/bash
#SBATCH -n 16                    
#SBATCH --time 24:00:00                 
#SBATCH --mem-per-cpu=8000    
#SBATCH -J dRep_strains_dereplication
#SBATCH -o zout_%x.%j_%A_%a.%u.out
#SBATCH --mail-user=marco.gabrielli@eawag.ch
#SBATCH --mail-type=ALL

main_folder="/cluster/work/eawag/p07003/Data/filteredGenomes_QC_manRef"
cd ${main_folder}

source activate drep-env
module load fastani

mkdir dRep_dereplication
# Get list of all genomes to dereplicate
ls */*.fna > dRep_dereplication/genomes_list

# Get CheckM2 info
if test -f "dRep_dereplication/checkm2.quality_report.tsv"; then
	echo "CheckM2 summary already present. Skipped"
else
	cat */checkm2_result/quality_report.tsv | sort | uniq > dRep_dereplication/checkm2.quality_report.tsv.tmp 
	tac dRep_dereplication/checkm2.quality_report.tsv.tmp | awk 'NR==1 {line =$0; next} 1; END{print line}' | tac > dRep_dereplication/checkm2.quality_report.tsv # To move last line to first (correcting headers)
	rm dRep_dereplication/checkm2.quality_report.tsv.tmp
fi

# Format CheckM2 info for dRep
# Select columns with completeness and contamination
awk -F"\t" '{print $2"," $3}' dRep_dereplication/checkm2.quality_report.tsv > dRep_dereplication/checkm2.quality_report_dRep_input.csv.tmp
sed -i 's/Completeness,Contamination/completeness,contamination/' dRep_dereplication/checkm2.quality_report_dRep_input.csv.tmp
# Add header to filepath
sed '1 i\genome' dRep_dereplication/genomes_list > dRep_dereplication/genomes_list_header.tmp
# Bind cols with filepaths and genomes info
paste --delimiters="," dRep_dereplication/genomes_list_header.tmp dRep_dereplication/checkm2.quality_report_dRep_input.csv.tmp > dRep_dereplication/checkm2.quality_report_dRep_input.csv
rm dRep_dereplication/checkm2.quality_report_dRep_input.csv.tmp dRep_dereplication/genomes_list_header.tmp

mkdir dRep_dereplication/dRep_strains_99.5ANI

dRep dereplicate -p 16 -g dRep_dereplication/genomes_list --genomeInfo dRep_dereplication/checkm2.quality_report_dRep_input.csv --S_algorithm fastANI --MASH_sketch 100000 --S_ani 0.995 -strW 0 --debug dRep_dereplication/dRep_strains_99.5ANI
