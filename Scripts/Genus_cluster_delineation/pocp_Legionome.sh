#!/bin/bash
#SBATCH -n 16                
#SBATCH --time 96:00:00                 
#SBATCH --mem-per-cpu=4000    
#SBATCH -J pocp_Legionome 
#SBATCH -o zout_%x.%j_%A_%a.%u.out
#SBATCH --mail-user=marco.gabrielli@eawag.ch
#SBATCH --mail-type=ALL

module load eth_proxy
source ~/miniconda3/bin/activate 
conda activate pocpnf-env

main_folder="/cluster/work/eawag/p07003/Data/legionomePangenome"

cd $main_folder

nextflow run hoelzer/pocp --proteins /cluster/work/eawag/p07003/Data/legionomePangenome/proteinFolder_legionome/faa_files/*.faa --max_cores 16 --memory 40 --output pocp_Legionome