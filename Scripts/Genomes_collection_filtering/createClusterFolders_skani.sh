cd /cluster/work/eawag/p07003/Data/filteredGenomes_QC_manRef/dRep_dereplication/secondaryClustering_skani

main_folder="/cluster/work/eawag/p07003/Data/filteredGenomes_QC_manRef/"

tail -n+2 /cluster/work/eawag/p07003/Data/filteredGenomes_QC_manRef/dRep_dereplication/dRep_primaryMASH/data_tables/Cdb.csv | awk -F"," '{print $2 > "/cluster/work/eawag/p07003/Data/filteredGenomes_QC_manRef/dRep_dereplication/secondaryClustering_skani/"$1"_primaryMASHcluster_list"}'

for i in *_primaryMASHcluster_list; do
	# Create destination folder
	d=${i::-5}
	echo "$d started"
	mkdir -p $d

	# Modify files list with actual target files
	awk -F"_" '{print $1}' ${i} > ${i}.tmp
	mv ${i}.tmp ${i}
	sed -i "s#Legio#${main_folder}Legio#" $i
	sed -i 's#$#*/*.fna#' $i

	for file in `cat $i`; do
		cp $file $d
	done

	echo "$d done"
done

