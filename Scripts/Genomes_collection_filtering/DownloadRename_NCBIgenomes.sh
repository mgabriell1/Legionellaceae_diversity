#!/bin/bash
#SBATCH -n 2                     
#SBATCH --time 04:00:00                  
#SBATCH --mem-per-cpu=4000     # 4000 MB per core
#SBATCH -J DownloadRename_NCBIgenomes
#SBATCH -o zout_%x.%j.%u.out
#SBATCH --mail-type=ALL

####
# This scripts downloads the genomes with an assembly accession number included in the list of non-redundant genomes
# and organizes the folder structure, prepending to folders and assembly files their LegioID
####

source activate ncbi_datasets

cd $WORK_LEGIONOME_GDC
echo "Working directory " `pwd`

cd Data

## Download and unzip genomes
datasets download genome accession --inputfile <(awk -F '\t' '{print $2}' LegioID_genomesTableNR.tsv | sed '/NA/d' | sed '/accession_assembly/d')
unzip ncbi_dataset 
mv ncbi_dataset downloadedGenomes

## Prepend LegioID to folders	
cd downloadedGenomes

# Organize folder
mv data/* .
rm -r data

# Prepare file for renaming folders and use for renaming
awk -F '\t' '{print $1 "\t" $2}' ../LegioID_genomesTableNR.tsv | sed '/NA/d' | sed '/accession_assembly/d' > assembly_to_LegioID
awk -F'\t' 'system("mv " $2 " " $1"_"$2)' assembly_to_LegioID

## Rename assembly within each folder
for d in */ ; do
    legioid=${d:0:10}
    file=`ls $d`
    mv $d/$file $d/${legioid}_$file
done
