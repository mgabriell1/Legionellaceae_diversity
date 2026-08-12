#!/bin/bash
#SBATCH -n 16                
#SBATCH --time 72:00:00                 
#SBATCH --mem-per-cpu=8000    
#SBATCH -J iqtree_pangenome_BUSCOsupermatrix 
#SBATCH -o zout_%x.%j_%A_%a.%u.out
#SBATCH --mail-user=marco.gabrielli@eawag.ch
#SBATCH --mail-type=ALL

main_folder="/cluster/work/eawag/p07003/Data/legionomePangenome"


IQTREE="/cluster/project/eawag/p07003/Software/iqtree-2.2.2.6-Linux/bin/iqtree2"

cd ${main_folder}/BUSCO_phylogenomics_Legionellales_odb12_Legionome/supermatrix

#input files from BUSCO_phylogenomics workflow

#cat SUPERMATRIX.partitions.nex | sed "s/SUPERMATRIX.phylip: //" > SUPERMATRIX.partitions.new.nex
# iqtree was behaving weird having that think nd there are no partitions to specify

$IQTREE -s SUPERMATRIX.phylip -p SUPERMATRIX.partitions.new.nex -m MFP+C+MERGE -mset LG,WAG -B 1000 -bnni -T 16 --cmin 10 --cmax 60

