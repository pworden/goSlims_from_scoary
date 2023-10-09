#!/bin/bash

#PBS -l ncpus=8
#PBS -l mem=64GB
#PBS -l walltime=24:00:00

# Start the r conda environment
source /shared/homes/118623/miniconda3/etc/profile.d/conda.sh # Path to conda
conda activate r

# ------------------------------------------------------------------------------
# ------------- UNIPROT DATA GATHERING BEFORE RUNNING THIS SCRIPT --------------
# -----> Get the gene ontology identifiers from uniprot
  # Load the goIdentifiers.txt (one column no header) into the uniprot retrieve/ID mapping page
      # https://www.uniprot.org/uploadlists/
      # -----> 
  # Select the columns webpage (this will remove the "Entry" column)
  # From	Entry	Reviewed	Protein names	Gene Names	Organism	Length	Gene Ontology (biological process)	Gene Ontology (cellular component)	Gene Ontology (molecular function)	Gene Ontology IDs
    # *****If the "Entry" column is not removed the next section may FAIL*****
  # Download the output as tab separated
# -----> Rename the output as "uniprotOutput.txt"
  # Copy "uniprotOutput.txt" into working directory
  # LIST of column names:
  # Reviewed, Entry Name, Protein names, Gene Names, Organism, Length, Gene Ontology (biological process), Gene Ontology (cellular component), Gene Ontology (molecular function), Gene Ontology IDs
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------


# R-packages that need to be pre-loaded into the conda R environment used by this script
# library("seqinr")
# library("stringr")
# library("tidyr")


# ------------------------------------------------------------------------------
# --------------------------- GOSLIMS FROM DIAMOND DB --------------------------
# Get the diamond output
inputForGoSlims="/shared/homes/118623/bee_project/scoary/scoary_output/scoary_filtered/roary_toScoary_Fasta/diamond_db_result/uniprot/uniprotOutput.txt"
outputDirForGoSlims=${inputForGoSlims%/*}
goidsScriptPath="/shared/homes/118623/bee_project/scoary/scoary_scripts/05_2_processGoSlims.R"
# NOTE: Output will be in the same directory as input (roary_toScoary_Fasta_diamond.out)

Rscript $goidsScriptPath $inputForGoSlims $outputDirForGoSlims
# ------------------------- End GoSlims from diamond DB ------------------------
# ------------------------------------------------------------------------------

