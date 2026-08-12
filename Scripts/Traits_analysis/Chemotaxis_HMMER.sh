module load  gcc/6.3.0
module load openmpi/3.0.1
module load hmmer

CHEMOTAXIS_HMMS="/cluster/project/eawag/p07003/Software/chemotaxis-models/che.hmm"
CheW_HMM="/cluster/project/eawag/p07003/Software/chemotaxis-models/PF01584.hmm"

cd /cluster/work/eawag/p07003/Data/legionomePangenome
mkdir Chemotaxis_HMMER_result

hmmsearch --tblout Chemotaxis_HMMER_result/Chemotaxis_Legionome_HMM.tsv -o Chemotaxis_HMMER_result/Chemotaxis_Legionome_HMMER_output.txt $CHEMOTAXIS_HMMS allProteins_legionomePangenome.faa 
# sequence bitscore threshold = 25, domain bitscore threshold = 22  #https://hmmer-web-docs.readthedocs.io/en/latest/searches.html

hmmsearch --tblout Chemotaxis_HMMER_result/Chemotaxis_Legionome_HMM_CheW.tsv -o Chemotaxis_HMMER_result/Chemotaxis_Legionome_HMMER_CheW_output.txt --cut_ga $CheW_HMM allProteins_legionomePangenome.faa 