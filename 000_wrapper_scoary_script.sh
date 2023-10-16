#!/bin/bash

#PBS -l ncpus=32
#PBS -l mem=128GB
#PBS -l walltime=48:00:00

# Create a directory (eg. "scoary") into which all initial scoary inputs will be placed
  # Inputs are: gene_presence_absence_roary_838_pl.csv, P_larvae_Scoary_Traits_838.csv, scoary_pan_genome_reference.fa
# ------------------------------------------------------------------------------
# --------------------------------- ALL INPUTS ---------------------------------
# The starting directory where all "scoary" initital inputs are placed
baseScoaryDirPath="/shared/homes/118623/bee_project/scoary"
# The scoary subdirectory where all outputs, including dirctories, are found
scoaryParentOutputDir=$baseScoaryDirPath"/scoary_output"
# The directory for all scoary scripts
pathToScoaryScriptsFolder=$baseScoaryDirPath"/scoary_scripts"
# Path to the roary (or panaroo [in roary format]) presence/absence CSV output
  # One of two scoary script inputs
roaryGenePresenceAbsenceCSV=$baseScoaryDirPath"/gene_presence_absence_roary_838_pl.csv"
# The traits CSV file - The second of two scoary inputs 
traitsInput=$baseScoaryDirPath"/P_larvae_Scoary_Traits_838.csv"
# The "pan_genome_reference.fa" file that will be subsetted using the scoary CSV output
  # The subsetted fasta will be used as input for the diamond database search for the 
  # protein identifiers needed to obtain gene ontology IDs and their terms 
roaryRefFasta=$baseScoaryDirPath"/scoary_pan_genome_reference.fa"

# Path to the Diamond database used
diamondDatabase="/shared/homes/118623/blobtools_db/uniprot/reference_proteomes.dmnd"
# Path the the generic Gene Ontology Slim database in OBO format
goslimGenericOBO="/shared/homes/118623/bee_project/scoary/goslim_generic.obo"
# -------------------------------- End All Inputs ------------------------------
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# ----------------------------------- SCOARY -----------------------------------
# Path to the scoary script
pathToScoaryScript=$pathToScoaryScriptsFolder"/01_examine_scoary_genes_of_interest.sh"
# Run the scoary script that will 
# The output will be a csv file in the "scoaryParentOutputDir" directory
bash $pathToScoaryScript $roaryGenePresenceAbsenceCSV $traitsInput $scoaryParentOutputDir
# ---------------------------------- End Scoary --------------------------------
# ------------------------------------------------------------------------------



# ------------------------------------------------------------------------------
# ----------------------- SCOARY OUTPUT FILTERED SUBSET ------------------------
# Start the r conda environment
source /shared/homes/118623/miniconda3/etc/profile.d/conda.sh # Path to conda
conda activate r
# Find the input file starting at the parent directory
pathToScoaryOuputCSV=($( find $scoaryParentOutputDir -maxdepth 2 -type f -name *".results.csv" ))
  # >>>>>-----<<<<<
# If you just want to use the default p-value of 0.05
# type in a value greater than 0.05 within the quotes (eg. 0.1)
pValueForFilter="0.001"
  # pValueForFilter="5.48575705636e-180" (format for scientific notation)
  # >>>>>-----<<<<<
# Path to the output directory
scoaryFilteredOutputDir=$scoaryParentOutputDir"/scoary_filtered"
# Path to the R-script to be called
pathToFilterScoaryRscript=$pathToScoaryScriptsFolder"/02_2_filterScoary.R"
# This script will make an output directory and subset the scoary table 
# based on a set criteria. It also produces a file of subsetted genes.
Rscript $pathToFilterScoaryRscript $pathToScoaryOuputCSV $pValueForFilter $scoaryFilteredOutputDir
# --------------------- End Scoary Filtered Output Subset ----------------------
# ------------------------------------------------------------------------------



# ------------------------------------------------------------------------------
# ---------- SUBSET ROARY FASTA WITH SCOARY SUBSETTED TABLE (ABOVE) ------------
# Reference Fasta file to be subsetted with this script, fasta used for diamond DB search
pathToRoaryFasta=$roaryRefFasta
# Output folder path
scoaryFilteredFastaOutDir=$scoaryFilteredOutputDir"/roary_toScoary_Fasta"
# Find the input file path
pathToFilteredScoaryGenes=($( find $scoaryFilteredOutputDir -maxdepth 2 -type f -name *"_genes.txt" ))
# Path to the script that will create a subsetted Fasta file from scoary deteremined gene set
pathToScoaryFilterFasta=$pathToScoaryScriptsFolder"/03_2_scoaryFilterFasta.R"
# Run the R-script
Rscript $pathToScoaryFilterFasta $pathToRoaryFasta $scoaryFilteredFastaOutDir $pathToFilteredScoaryGenes
# --------------------------- End Subset Roary Fasta ---------------------------
# ------------------------------------------------------------------------------



# ------------------------------------------------------------------------------
# --------------------------- DIAMOND DATABASE SEARCH --------------------------
# Path to the subsetted Fasta file of proteins most likely found in only one or more traits 
diamondinputFasta=$scoaryFilteredFastaOutDir"/scoaryGeneList.fasta"
# Output Folder for the Diamond database search
diamondOutDirPath=$scoaryFilteredFastaOutDir"/diamond_db_result"
# Path to the diamond database
diamondDatabasePath=$diamondDatabase
# Path to the Diamond script
diamondBlastxScript=$pathToScoaryScriptsFolder"/Diamond_Blastx_Script.sh"
# Deactivate the r conda environment - The next script being called starts its own conda environment
conda deactivate
# Search for proteins via the subsetted fasta file obtained from the previous of
# DNA sequences (genes) using the diamond database
bash $diamondBlastxScript $diamondinputFasta $diamondOutDirPath $diamondDatabasePath
# ------------------------- End Diamond database Search ------------------------
# ------------------------------------------------------------------------------



# ------------------------------------------------------------------------------
# ----------------- GET PROTEIN IDs FROM DIAMOND SEARCH OUTPUT -----------------
# Start the r conda environment
source /shared/homes/118623/miniconda3/etc/profile.d/conda.sh # Path to conda
conda activate r
# Get the diamond output from the protein search
inputForUniprotIDs_RScript=$diamondOutDirPath"/roary_toScoary_Fasta_diamond.out"
# Path to the script to gather protein IDs of interest
getUniprotIDs_R_Script=$pathToScoaryScriptsFolder"/04_2_getUniprotIDs_fromBlastxInput.R"
# Script to tidy up the diamond output table and save this as a CSV
  # and write a text file of listing Proteins of interest
# NOTE: Output will be in the same directory as input (roary_toScoary_Fasta_diamond.out)
Rscript $getUniprotIDs_R_Script $inputForUniprotIDs_RScript # $outputForForUniprotIDs_RScript
# ------------------------- End GoSlims from diamond DB ------------------------
# ------------------------------------------------------------------------------


    # ------------------------------------------------------------------------------
    # ------------------------------------------------------------------------------
    # ------------------------------------------------------------------------------
    # ----------------- MANUAL PREPARATION OF DATA FOR NEXT SCRIPT -----------------
    # Future potential to automate the gathering of gene ontology information from
    # a list of protein identifiers. APIs exist as do R and Python apps for this purpose.
    # To continue with manual gathering of gene ontology info, see description below ----->
    # ------------------------------ End Description -------------------------------
    # ------------------------------------------------------------------------------


    # ------------------------------------------------------------------------------
    # ---------------- UNIPROT DATA GATHERING AFTER RUNNING SCRIPT -----------------
    # -----> Get the gene ontology identifiers from uniprot
      # Load the goIdentifiers.txt (one column no header) into the uniprot retrieve/ID mapping page
          # https://www.uniprot.org/uploadlists/
          # -----> 
      # Select the columns webpage (this will remove the "Entry" column)
      # From	Entry	Reviewed	Protein names	Gene Names	Organism	Length	Gene Ontology (biological process)	Gene Ontology (cellular component)	Gene Ontology (molecular function)	Gene Ontology IDs
        # *****If the "Entry" column is not removed the next section may FAIL*****
      # Download the output as tab separated
    # -----> Rename the output as "uniprotOutput.txt"
      # Copy "uniprotOutput.txt" into the "uniprot" directory created by the previous section -
        # (GET PROTEIN IDs FROM DIAMOND SEARCH OUTPUT)
      # LIST of column names for the downloaded uniprot table:
        # Reviewed, Entry Name, Protein names, Gene Names, Organism, Length, Gene Ontology (biological process), Gene Ontology (cellular component), Gene Ontology (molecular function), Gene Ontology IDs
    # ------------------------------------------------------------------------------
    # ------------------------------------------------------------------------------
    # ------------------------------------------------------------------------------
    # ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# ---------------------- GET GO IDENTIFIERS AND GO SLIMS -----------------------
# The conda r environment is need but should still be active from before
    # example path: workingDir="/shared/homes/118623/bee_project/scoary/scoary_output/scoary_filtered/roary_toScoary_Fasta/diamond_db_result"
workingDir=$diamondOutDirPath
# The output directory
    # example path: outputBaseDir="/shared/homes/118623/bee_project/scoary/scoary_output/scoary_filtered/roary_toScoary_Fasta/diamond_db_result/uniprot"
outputBaseDir=$workingDir/"uniprot"
# The input Obo file needed to determine the GO Slims
      # example path: OboFileInput="/shared/homes/118623/bee_project/scoary/goslim_generic.obo"
goslimGenericOBO="/shared/homes/118623/bee_project/scoary/goslim_generic.obo"
# The R script that will get the gene ontology identifiers from the protein IDs -
  # and then summarise the gene ontology identifiers through GO SLIMS
quickGoAndGoSlimsOuputScript=$pathToScoaryScriptsFolder"/04_5_2_quickGoAndGoSlimsOuput.R"

# Run the R-script
Rscript $quickGoAndGoSlimsOuputScript $workingDir $outputBaseDir $goslimGenericOBO
# ------------------- End get GO identifiers and GO Slims ----------------------
# ------------------------------------------------------------------------------



# >>>>>>>>>>>>>>>>>>>>>>>>> EXTRA CODE <<<<<<<<<<<<<<<<<<<<<<

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

