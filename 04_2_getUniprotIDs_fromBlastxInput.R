#!/usr/bin/R Rscript

# Prepare R to input arguments with the script
args = commandArgs(trailingOnly=TRUE)

library("stringr")
  # library("reshape2")
  # library("tidyr")
  # inputFileAndPath = "/shared/homes/118623/bee_project/scoary/scoary_test_output/scoary_filtered/roary_toScoary_Fasta/diamond_db_result/roary_toScoary_Fasta_diamond.out"
inputFileAndPath = args[1]


diamondFileName = basename(inputFileAndPath)
diamondDirPath = dirname(inputFileAndPath)
uniprotOutPath = paste0(diamondDirPath, "/", "uniprot")


if (dir.exists(uniprotOutPath)) {
  print(paste0(uniprotOutPath, " ... already exists!"))
} else {
  dir.create(uniprotOutPath)
}

blastxColumnNames = c("qseqid", "qstart", "qend", "sseqid", "sstart", "send", "staxids", "pident", "length", "mismatch", "gapopen", "evalue", "bitscore")


setwd(diamondDirPath)

# blastxDataFrame = read.delim(file = inputFileName, col.names = blastxColumnNames)
blastxDataFrame = read.delim(file = inputFileAndPath, col.names = blastxColumnNames)

proteinIdentifiers = blastxDataFrame$sseqid
proteinIdentifiers = str_split(proteinIdentifiers, pattern = "\\|", 3)

column = NULL
for (i in 1:nrow(blastxDataFrame)) {
  temp_column = proteinIdentifiers[[i]][[2]]
  column = c(column, temp_column)
}

# Take the multiple Identifiers (3 types) from the sseqid column and save only one for that column
blastxDataFrame$identifiers = column
blastxDataFrame = blastxDataFrame[, c(ncol(blastxDataFrame), 2:ncol(blastxDataFrame)-1)]
# Save the data frame
write.csv(blastxDataFrame, "modifiedBlastxResults.csv", row.names = FALSE)
Id_only_blastxDataFrame = blastxDataFrame["identifiers"]
write.table(Id_only_blastxDataFrame, "UniprotIdentifiers_input.txt", row.names = FALSE, col.names = FALSE, quote = FALSE, sep = "\t")

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
  # Copy "uniprotOutput.txt" into working directory
  # LIST of column names:
  # Reviewed, Entry Name, Protein names, Gene Names, Organism, Length, Gene Ontology (biological process), Gene Ontology (cellular component), Gene Ontology (molecular function), Gene Ontology IDs
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
