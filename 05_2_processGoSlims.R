#!/usr/bin/R

# Prepare R to input arguments with the script
args = commandArgs(trailingOnly=TRUE)

library("seqinr")
library("stringr")
library("tidyr")
# library("reshape2")


# uniProtOutput = "/shared/homes/118623/bee_project/scoary/scoary_test_output/scoary_filtered/roary_toScoary_Fasta/diamond_db_result/uniprot/uniprotOutput.txt"
# outputDirForGoSlims = "/shared/homes/118623/bee_project/scoary/scoary_test_output/scoary_filtered/roary_toScoary_Fasta/diamond_db_result/uniprot"
uniProtOutput = args[1]
outputDirForGoSlims = args[2]
uniprotFileName = basename(uniProtOutput)
uniprotDirPath = dirname(uniProtOutput)

# Create a new table of just the 
GeneOntologyTable = read.delim(file = uniProtOutput, stringsAsFactors = FALSE, check.names = FALSE)

names(GeneOntologyTable) = gsub("[^[:alnum:]]", "___", names(GeneOntologyTable))
names(GeneOntologyTable) = gsub("__|___", "_", names(GeneOntologyTable))
names(GeneOntologyTable) = gsub("__", "_", names(GeneOntologyTable))
names(GeneOntologyTable) = gsub("_$", "", names(GeneOntologyTable))

proteinIdsAndGoIds = GeneOntologyTable[,c("Entry", "Gene_Ontology_IDs")]
noMissingRows_proteinIdsAndGoIds = proteinIdsAndGoIds[!apply(is.na(proteinIdsAndGoIds) | proteinIdsAndGoIds == "", 1, any),]
missingRows_proteinIdsAndGoIds = proteinIdsAndGoIds[apply(is.na(proteinIdsAndGoIds) | proteinIdsAndGoIds == "", 1, any),]
totalRows = nrow(proteinIdsAndGoIds)
numberMissingRows = nrow(missingRows_proteinIdsAndGoIds)
# Number of identifiers with missing GO data
percentMissingRows = round(numberMissingRows/totalRows*100, digits=2)

#Create a table of present/missing rows and save as csv
numberMissingRowsDF = data.frame(Total_Rows = totalRows, Missing_Row_Data = numberMissingRows, Percent_Missing_Rows = percentMissingRows)
write.csv(numberMissingRowsDF, paste0(outputDirForGoSlims, "/", "percentOfGeneOntologyHits.csv"), row.names = FALSE)

oneRowPerGoId = separate_rows(noMissingRows_proteinIdsAndGoIds, Gene_Ontology_IDs, sep = ";")
oneRowPerGoId = as.data.frame(apply(oneRowPerGoId, 2, function(x) gsub("\\s+", "", x)))

# Save protein and their gene-ontology identifiers as a tab delimited file
  # This tab delimited file can then be placed into "GOSlimViewer"
write.table(oneRowPerGoId, paste0(outputDirForGoSlims, "/", "ProteinAndGoIds_forGoSlimViewer.tsv"), row.names = FALSE, col.names = FALSE, quote = FALSE, sep = "\t")
