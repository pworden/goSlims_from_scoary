#!/bin/bash

# Given a gene presence absence file from roary or in the roary format, say from panaroo, this script
# will also input a traits table and find traits genes that are found in one trait.
# The output will be to a folder whose path is defined by the user

# Start conda environment
source /shared/homes/118623/miniconda3/etc/profile.d/conda.sh # Path to conda
conda activate scoary

# ------------------------------------------------------------------------------
# --------------------------------- USER INPUTS --------------------------------
# Access the command-line arguments
    # # Test Paths
    # genePresenceAbsenceCSV="/Users/paulworden/Library/CloudStorage/OneDrive-DPIE/General_and_Overall/Journal_papers/Bee_Brood_Diseases/AFB/Sept_2023_Draft/Panaroo_Pan_Genome/scoary/gene_presence_absence_roary_838_pl.csv"
    # traitsInput="/Users/paulworden/Library/CloudStorage/OneDrive-DPIE/General_and_Overall/Journal_papers/Bee_Brood_Diseases/AFB/Sept_2023_Draft/Panaroo_Pan_Genome/scoary/P_larvae_Scoary_Traits_838.csv"
    # outputDir="/Users/paulworden/Library/CloudStorage/OneDrive-DPIE/General_and_Overall/Journal_papers/Bee_Brood_Diseases/AFB/Sept_2023_Draft/Panaroo_Pan_Genome/scoary/scoary_test_output"
genePresenceAbsenceCSV="$1"
traitsInput="$2"
outputDir="$3"
# ------------------------------- End User Inputs ------------------------------
# ------------------------------------------------------------------------------


if [ -e $outputDir ]; then echo "Folder exists!"; else mkdir $outputDir; echo "Creating folder: $outputDir"; fi

scoary -g $genePresenceAbsenceCSV -t $traitsInput -o $outputDir
