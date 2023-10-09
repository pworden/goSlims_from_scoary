# GO_Slims_Summary
Gene or protein list to blast search to gene ontology summary

# Scoary to gene ontology summaries
This page summarises the steps that the **00_0_overall_scoary_script.sh** script performs. Which is to run scoary, get protein identifiers from the genes of interest, and then get and summarise gene ontology information from the proteins of interest.

## Initial Setup
Before running the Scoary pipeline, ensure that you have set up the necessary directories and have the required input files ready.

### Directory Structure
- Create a directory named "scoary" to store all initial Scoary inputs.
- Inside the "scoary" directory, you should have the following initial input files:
  - `gene_presence_absence_roary_838_pl.csv`: Roary (or panaroo) presence/absence CSV output.
  - `P_larvae_Scoary_Traits_838.csv`: Traits CSV file.
  - `scoary_pan_genome_reference.fa`: The reference FASTA file for pan-genome analysis.

### Create a scoary conda environment
```Bash
conda create --name scoary
# Activate the environment
conda activate scoary
# Install the scoary program into the new environment 
conda install -c bioconda scoary
```

### Create an R environment for scoary and add some necessary R packages
```Bash
conda create --name r-base
# Activate the environment
conda activate r-base
# Install the r-base (R plus selected R-packages)
conda install -c conda-forge r-base
# Also install the seqinr package
conda install -c bioconda r-seqinr
# The stringr package
conda install -c conda-forge r-stringr
# The tidyr package
conda install -c conda-forge r-tidyr

# Or start R on the server within the conda environment and install normally
# Example:
R                           # This will start the R interpreter
install.package("seqinr)    # To install the package "seqinr"
quit()                      # To quit R
```

# Run the main (1st) scoary script
#####Run the following script to get proteins and their gene ontology information
- **00_0_overall_scoary_script.sh**

## Script Inputs
Set the paths to various input files and directories.

```Bash
baseScoaryDirPath="/shared/homes/118623/bee_project/scoary"
scoaryParentOutputDir="$baseScoaryDirPath/scoary_output"
pathToScoaryScriptsFolder="$baseScoaryDirPath/scoary_scripts"
roaryGenePresenceAbsenceCSV="$baseScoaryDirPath/gene_presence_absence_roary_838_pl.csv"
traitsInput="$baseScoaryDirPath/P_larvae_Scoary_Traits_838.csv"
roaryRefFasta="$baseScoaryDirPath/scoary_pan_genome_reference.fa"
diamondDatabase="/shared/homes/118623/blobtools_db/uniprot/reference_proteomes.dmnd"
```

### 1. Running Scoary
Run the Scoary script **"00_0_overall_scoary_script.sh"** which will invoke a number of different bash and R scripts. An overview of all the stages is outlined below.

```Bash
pathToScoaryScript="$pathToScoaryScriptsFolder/01_examine_scoary_genes_of_interest.sh"
bash $pathToScoaryScript $roaryGenePresenceAbsenceCSV $traitsInput $scoaryParentOutputDir
```

### 2. Filtering Scoary Output
Filter the Scoary output based on a specified p-value threshold and create a filtered output directory.

```Bash
# Activate the R conda environment
source /shared/homes/118623/miniconda3/etc/profile.d/conda.sh
conda activate r

# Find the Scoary output CSV file
pathToScoaryOuputCSV=($( find $scoaryParentOutputDir -maxdepth 2 -type f -name *".results.csv" ))

# Set the p-value threshold for filtering
pValueForFilter="0.001"

# Specify the output directory for filtered results
scoaryFilteredOutputDir="$scoaryParentOutputDir/scoary_filtered"

# Run the filtering script
pathToFilterScoaryRscript="$pathToScoaryScriptsFolder/02_2_filterScoary.R"
Rscript $pathToFilterScoaryRscript $pathToScoaryOuputCSV $pValueForFilter $scoaryFilteredOutputDir
```

### 3. Subset Roary FASTA
Subset the Roary reference FASTA file based on the genes identified in the filtered Scoary results.

```Bash
# Set the paths and variables
pathToRoaryFasta="$roaryRefFasta"
scoaryFilteredFastaOutDir="$scoaryFilteredOutputDir/roary_toScoary_Fasta"
pathToFilteredScoaryGenes=($( find $scoaryFilteredOutputDir -maxdepth 2 -type f -name *"_genes.txt" ))
pathToScoaryFilterFasta="$pathToScoaryScriptsFolder/03_2_scoaryFilterFasta.R"

# Run the R-script
Rscript $pathToScoaryFilterFasta $pathToRoaryFasta $scoaryFilteredFastaOutDir $pathToFilteredScoaryGenes
```

### 4. Diamond Database Search
Perform a Diamond database search using the subsetted FASTA file to find protein identifiers.

```Bash
# Set the paths and variables
diamondinputFasta="$scoaryFilteredFastaOutDir/scoaryGeneList.fasta"
diamondOutDirPath="$scoaryFilteredFastaOutDir/diamond_db_result"
diamondDatabasePath="$diamondDatabase"
diamondBlastxScript="$pathToScoaryScriptsFolder/Diamond_Blastx_Script.sh"

# Deactivate the R conda environment
conda deactivate

# Run the Diamond database search
bash $diamondBlastxScript $diamondinputFasta $diamondOutDirPath $diamondDatabasePath
```

***

### 5. Extracting Protein IDs from Diamond Output
Retrieve protein identifiers from the Diamond search output.

```Bash
# Activate the R conda environment again
source /shared/homes/118623/miniconda3/etc/profile.d/conda.sh
conda activate r

# Set the paths and variables
inputForUniprotIDs_RScript="$diamondOutDirPath/roary_toScoary_Fasta_diamond.out"
outputForForUniprotIDs_RScript="$diamondOutDirPath/uniprot"
getUniprotIDs_R_Script="$pathToScoaryScriptsFolder/04_2_getUniprotIDs_fromBlastxInput.R"

# Run the R-script
Rscript $getUniprotIDs_R_Script $inputForUniprotIDs_RScript $outputForForUniprotIDs_RScript
```

***

# Initial (1st) script completion
***
## Manual Data Gathering before next automated stage

### Gene ontology identifiers
To gather gene ontology identifiers from Uniprot, follow these manual steps:

1. Load the goIdentifiers.txt (one column, no header) into the Uniprot Retrieve/ID Mapping page.
   - https://www.uniprot.org/id-mapping
2. Select the desired columns and download the output as tab-separated text.
3. Rename the downloaded file to "uniprotOutput.txt."
4. Copy "uniprotOutput.txt" into the "uniprot" directory created by the script.

- The Uniprot table columns include:
  - Reviewed
  - Entry Name
  - Protein names
  - Gene Names
  - Organism
  - Length
  - Gene Ontology (biological process)
  - Gene Ontology (cellular component)
  - Gene Ontology (molecular function)
  - Gene Ontology IDs

***

# Run the final (2st) scoary script
#####Run the following script to get proteins and their gene ontology information
- **00_1_overall_scoary_script.sh**

This script gets the gene ontology data from the uniprot data (manual stage above), then:

1. Outputs a two column table of uniprot IDs and associated gene ontology IDs
2. Outputs a small table summarising how many protein IDs had associated IDs

```Bash
#Inputs for the wrapper script (00_1_overall_scoary_script.sh)
inputForGoSlims="/shared/homes/118623/bee_project/scoary/scoary_output/scoary_filtered/roary_toScoary_Fasta/diamond_db_result/uniprot/uniprotOutput.txt"
goidsScriptPath="/shared/homes/118623/bee_project/scoary/scoary_scripts/05_2_processGoSlims.R"
outputDirForGoSlims=${inputForGoSlims%/*}
# NOTE: Output will be in the same directory as input (roary_toScoary_Fasta_diamond.out)
```

*Essentially this script will prepare the gene ontology data obtained from uniprot for input into the web service called "goSlim Viewer".*

***

# Next steps:
1. Input the resulting table of goSlims into the web service called "goSlim Viewer".
(https://agbase.arizona.edu/cgi-bin/tools/goslimviewer_select.pl)
2. Found at theAgBase web site.
(https://agbase.arizona.edu/cgi-bin/tools/goslimviewer_select.pl)
3. The goSlims output can then be put into the web service Revigo for further summaries.
(http://revigo.irb.hr/)
* The program CirGo also gives a good graphic summary for the three GeneOntology categories.
(https://github.com/IrinaVKuznetsova/CirGO)

