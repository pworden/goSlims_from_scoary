#!/bin/bash

source /shared/homes/118623/miniconda3/etc/profile.d/conda.sh # Path to conda
conda activate r

scoaryOutputDir="/shared/homes/118623/bee_project/scoary/scoary_test_output"
scoaryFilteredOutputDir=$scoaryOutputDir"/scoary_filtered"
pathToRoaryFasta="/shared/homes/118623/bee_project/scoary/scoary_pan_genome_reference.fa"
scoaryFilteredFastaOutDir=$scoaryFilteredOutputDir"/roary_toScoary_Fasta"



# ------------------------------------------------------------------------------
# --------------------------- DIAMOND DATABASE SEARCH --------------------------
diamondinputFasta="/shared/homes/118623/bee_project/scoary/scoary_test_output/scoary_filtered/roary_toScoary_Fasta/scoaryGeneList.fasta"
diamondOutDirPath=$scoaryFilteredFastaOutDir"/diamond_db_result"
diamondDatabasePath="/shared/homes/118623/blobtools_db/uniprot/reference_proteomes.dmnd"
diamondBlastxScript="/shared/homes/118623/bee_project/scoary/scoary_scripts/Diamond_Blastx_Script.sh"

bash $diamondBlastxScript $diamondinputFasta $diamondOutDirPath $diamondDatabasePath
# Search for proteins via the subsetted fasta file obtained from the previous of DNA sequences (genes) using the diamond database

# ------------------------- End Diamond database Search ------------------------
# ------------------------------------------------------------------------------
