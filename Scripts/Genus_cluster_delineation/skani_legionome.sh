#!/bin/bash
#SBATCH -n 4                    
#SBATCH --time 12:00:00                 
#SBATCH --mem-per-cpu=8000    
#SBATCH -J skani_legionome
#SBATCH -o zout_%x.%j_%A_%a.%u.out
#SBATCH --mail-user=marco.gabrielli@eawag.ch
#SBATCH --mail-type=ALL

conda activate skani-env

cd /cluster/work/eawag/p07003/Data/legionomePangenome

#skani triangle genomesFolder_legionome/* --ci --detailed --full-matrix -o skani_legionome/skani_legionome_fullmatrix.tsv -t 4

mkdir skani_legionome
ls genomesFolder_legionome/*.fna > genomes_list.txt
for g in genomesFolder_legionome/*.fna; do
	skani dist -q $g -rl genomes_list.txt --ci -o skani_legionome/${g:24:10}_skani.tsv
done