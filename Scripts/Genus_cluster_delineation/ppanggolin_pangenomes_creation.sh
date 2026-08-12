#!/bin/bash
#SBATCH -n 8                
#SBATCH --time 24:00:00                 
#SBATCH --mem-per-cpu=8000    
#SBATCH -J ppanggolin_pangenomes
#SBATCH -o zout_%x.%j_%A_%a.%u.out
#SBATCH --mail-user=marco.gabrielli@eawag.ch
#SBATCH --mail-type=ALL


main_folder="/cluster/work/eawag/p07003/Data/legionomePangenome"
cd ${main_folder}

source ~/Software/miniconda/bin/activate 
conda activate ppanggolin-env

## All genomes
echo "####################### All genomes #############################"
ls Legio*/bakta_result/bakta_files/*.gbff > ppanggolin_annotations_files.tmp
cat ppanggolin_annotations_files.tmp | awk -F _ '{print $1}' > ppanggolin_annotations_names.tmp
paste -d "\t" ppanggolin_annotations_names.tmp ppanggolin_annotations_files.tmp > ppanggolin_annotations_list_all.tsv
rm  ppanggolin_annotations_files.tmp ppanggolin_annotations_names.tmp

ppanggolin workflow --anno ppanggolin_annotations_list_all.tsv -o ppanggolin_output_Legionome --basename Legionome  -c 8 --identity 0.5

cd ppanggolin_output_Legionome
#ppanggolin rarefaction -p Legionome.h5 --max 164 -o rarefaction_allLegionome_genomes -c 8
ppanggolin rgp -p Legionome.h5
ppanggolin write -p Legionome.h5 --regions --output regions_genome_plasticity
ppanggolin write -p Legionome.h5 --families_tsv -o gene_families
ppanggolin msa -p Legionome.h5 --partition persistent --phylo --single_copy -c 8 --output msa_singleCopy_persistent
ppanggolin msa -p Legionome.h5 --partition softcore --phylo --single_copy -c 8 --output msa_singleCopy_softcore
cd ..

## Only known species
echo "####################### known species #############################"
grep -v "Not named" ../LegioID_legionomePangenome_genus.tsv | grep -v "legio_id" | awk -F "\t" '{print $1}' > ppanggolin_annotations_names_knownSpecies.tmp
ls $(cat ppanggolin_annotations_names_knownSpecies.tmp | sed 's#$#*/bakta_result/bakta_files/*.gbff#') > ppanggolin_annotations_files_knownSpecies.tmp
paste -d "\t" ppanggolin_annotations_names_knownSpecies.tmp ppanggolin_annotations_files_knownSpecies.tmp > ppanggolin_annotations_list_knownSpecies.tsv
rm ppanggolin_annotations_names_knownSpecies.tmp ppanggolin_annotations_files_knownSpecies.tmp

ppanggolin workflow --anno ppanggolin_annotations_list_knownSpecies.tsv -o ppanggolin_output_Legionome_knownSpecies --basename Legionome_knownSpecies -c 8 --identity 0.5

# ## Only genus_cluster 1
# echo "####################### Genus cluster 1 #############################"
# cat ../LegioID_legionomePangenome_genus.tsv | awk -F "\t" '{if ($16 == 1) {print $1} }' > ppanggolin_annotations_names_genusCluster1.tmp
# ls $(cat ppanggolin_annotations_names_genusCluster1.tmp | sed 's#$#*/bakta_result/bakta_files/*.gbff#') > ppanggolin_annotations_files_genusCluster1.tmp
# paste -d "\t" ppanggolin_annotations_names_genusCluster1.tmp ppanggolin_annotations_files_genusCluster1.tmp > ppanggolin_annotations_list_genusCluster1.tsv
# rm ppanggolin_annotations_names_genusCluster1.tmp ppanggolin_annotations_files_genusCluster1.tmp

# ppanggolin workflow --anno ppanggolin_annotations_list_genusCluster1.tsv -o ppanggolin_output_Legionome_genusCluster1 --basename Legionome_genusCluster1 -c 8

# ## Only genus_cluster_literature 1 (belonging to genus_cluster 1)
# echo "####################### Genus cluster literature 1 #############################"
# cat ../LegioID_legionomePangenome_genus.tsv | awk -F "\t" '{if ($17 == 1) {print $1} }' > ppanggolin_annotations_names_genusClusterLiterature1.tmp
# ls $(cat ppanggolin_annotations_names_genusClusterLiterature1.tmp | sed 's#$#*/bakta_result/bakta_files/*.gbff#') > ppanggolin_annotations_files_genusClusterLiterature1.tmp
# paste -d "\t" ppanggolin_annotations_names_genusClusterLiterature1.tmp ppanggolin_annotations_files_genusClusterLiterature1.tmp > ppanggolin_annotations_list_genusClusterLiterature1.tsv
# rm ppanggolin_annotations_names_genusClusterLiterature1.tmp ppanggolin_annotations_files_genusClusterLiterature1.tmp

#ppanggolin workflow --anno ppanggolin_annotations_list_genusClusterLiterature1.tsv -o ppanggolin_output_Legionome_genusClusterLiterature1 --basename Legionome_genusClusterLiterature1 -c 8

# ## Only genus_cluster_literature 28 (belonging to genus_cluster 1)
# echo "####################### Genus cluster literature 1 #############################"
# cat ../LegioID_legionomePangenome_genus.tsv | awk -F "\t" '{if ($17 == 28) {print $1} }' > ppanggolin_annotations_names_genusClusterLiterature28.tmp
# ls $(cat ppanggolin_annotations_names_genusClusterLiterature28.tmp | sed 's#$#*/bakta_result/bakta_files/*.gbff#') > ppanggolin_annotations_files_genusClusterLiterature28.tmp
# paste -d "\t" ppanggolin_annotations_names_genusClusterLiterature28.tmp ppanggolin_annotations_files_genusClusterLiterature28.tmp > ppanggolin_annotations_list_genusClusterLiterature28.tsv
# rm ppanggolin_annotations_names_genusClusterLiterature28.tmp ppanggolin_annotations_files_genusClusterLiterature28.tmp

# ppanggolin workflow --anno ppanggolin_annotations_list_genusClusterLiterature28.tsv -o ppanggolin_output_Legionome_genusClusterLiterature28 --basename Legionome_genusClusterLiterature28 -c 8



# ## Only genus_cluster 5
# echo "####################### Genus cluster 5 #############################"
# cat ../LegioID_legionomePangenome_genus.tsv | awk -F "\t" '{if ($16 == 5) {print $1} }' > ppanggolin_annotations_names_genusCluster5.tmp
# ls $(cat ppanggolin_annotations_names_genusCluster5.tmp | sed 's#$#*/bakta_result/bakta_files/*.gbff#') > ppanggolin_annotations_files_genusCluster5.tmp
# paste -d "\t" ppanggolin_annotations_names_genusCluster5.tmp ppanggolin_annotations_files_genusCluster5.tmp > ppanggolin_annotations_list_genusCluster5.tsv
# rm ppanggolin_annotations_names_genusCluster5.tmp ppanggolin_annotations_files_genusCluster5.tmp

# ppanggolin workflow --anno ppanggolin_annotations_list_genusCluster5.tsv -o ppanggolin_output_Legionome_genusCluster5 --basename Legionome_genusCluster5 -c 8

# ## Only genus_cluster 6
# echo "####################### Genus cluster 6 #############################"
# cat ../LegioID_legionomePangenome_genus.tsv | awk -F "\t" '{if ($16 == 6) {print $1} }' > ppanggolin_annotations_names_genusCluster6.tmp
# ls $(cat ppanggolin_annotations_names_genusCluster6.tmp | sed 's#$#*/bakta_result/bakta_files/*.gbff#') > ppanggolin_annotations_files_genusCluster6.tmp
# paste -d "\t" ppanggolin_annotations_names_genusCluster6.tmp ppanggolin_annotations_files_genusCluster6.tmp > ppanggolin_annotations_list_genusCluster6.tsv
# rm ppanggolin_annotations_names_genusCluster6.tmp ppanggolin_annotations_files_genusCluster6.tmp 

# ppanggolin workflow --anno ppanggolin_annotations_list_genusCluster6.tsv -o ppanggolin_output_Legionome_genusCluster6 --basename Legionome_genusCluster6 -c 8

# ## Only genus_cluster 13
# echo "####################### Genus cluster 13#############################"
# cat ../LegioID_legionomePangenome_genus.tsv | awk -F "\t" '{if ($16 == 13) {print $1} }' > ppanggolin_annotations_names_genusCluster13.tmp
# ls $(cat ppanggolin_annotations_names_genusCluster13.tmp | sed 's#$#*/bakta_result/bakta_files/*.gbff#') > ppanggolin_annotations_files_genusCluster13.tmp
# paste -d "\t" ppanggolin_annotations_names_genusCluster13.tmp ppanggolin_annotations_files_genusCluster13.tmp > ppanggolin_annotations_list_genusCluster13.tsv
# rm ppanggolin_annotations_names_genusCluster13.tmp ppanggolin_annotations_files_genusCluster13.tmp

# ppanggolin workflow --anno ppanggolin_annotations_list_genusCluster13.tsv -o ppanggolin_output_Legionome_genusCluster13 --basename Legionome_genusCluster13 -c 8
