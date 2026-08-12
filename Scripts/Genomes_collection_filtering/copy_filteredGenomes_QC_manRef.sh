cd /cluster/work/eawag/p07003/Data

mkdir filteredGenomes_QC_manRef

manRef_genomes=`awk '$13 ~ /manualRef/ { print "downloadedGenomes_manualRefinement/"$1"*"}' LegioID_genomesTableNR_QCfiltered_manRef.tsv`
cp -r ${manRef_genomes} filteredGenomes_QC_manRef

downloaded_genomes=`awk '$13 !~ /manualRef/ { print "downloadedGenomes/"$1"*"}' LegioID_genomesTableNR_QCfiltered_manRef.tsv`
cp -r ${downloaded_genomes} filteredGenomes_QC_manRef