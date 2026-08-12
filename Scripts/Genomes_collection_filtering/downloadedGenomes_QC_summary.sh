cd $WORK_LEGIONOME_EAWAG/Data/downloadedGenomes

cat */checkm2_result/quality_report.tsv | sort | uniq > downloadedGenomes_checkm2.quality_report.tsv.tmp
tac downloadedGenomes_checkm2.quality_report.tsv.tmp | awk 'NR==1 {line =$0; next} 1; END{print line}' | tac > downloadedGenomes_checkm2.quality_report.tsv # To move last line to first (correcting headers)
rm downloadedGenomes_checkm2.quality_report.tsv.tmp
cat */gunc_result/GUNC.progenomes_2.1.maxCSS_level.tsv | sort | uniq > downloadedGenomes_GUNC.progenomes_2.1.maxCSS_level.tsv
cat */gtdbtk_result/classify/gtdbtk.bac120.summary.tsv | sort | uniq > downloadedGenomes_gtdbtk.bac120.summary.tsv.tmp
tac downloadedGenomes_gtdbtk.bac120.summary.tsv.tmp | awk 'NR==1 {line =$0; next} 1; END{print line}' | tac > downloadedGenomes_gtdbtk.bac120.summary.tsv
rm downloadedGenomes_gtdbtk.bac120.summary.tsv.tmp
