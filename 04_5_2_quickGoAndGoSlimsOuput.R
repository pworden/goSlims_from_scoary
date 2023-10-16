
#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)

library(httr)
library(jsonlite)
library(GSEABase)
  # if (!require("BiocManager", quietly = TRUE))
  #     install.packages("BiocManager")
  # BiocManager::install("GO.db")
library(GO.db)
# library(tidyverse)

# --------------------------------------------------------------------------------
# ---------------------------------- USER INPUT ----------------------------------
workingDir = args[1]
  # workingDir = "/shared/homes/118623/bee_project/scoary/scoary_output/scoary_filtered/roary_toScoary_Fasta/diamond_db_result"

outputBaseDir = args[2]
  # outputBaseDir = "/shared/homes/118623/bee_project/scoary/scoary_output/scoary_filtered/roary_toScoary_Fasta/diamond_db_result/uniprot"

OboFileInput = args[3]
  # OboFileInput = "/shared/homes/118623/bee_project/scoary/goslim_generic.obo"
# -------------------------------- End User Input --------------------------------
# --------------------------------------------------------------------------------

# workingDir = "/shared/homes/118623/bee_project/scoary/scoary_output/scoary_filtered/roary_toScoary_Fasta/diamond_db_result"
# outputBaseDir = "/shared/homes/118623/bee_project/scoary/scoary_output/scoary_filtered/roary_toScoary_Fasta/diamond_db_result/uniprot"
# OboFileInput = "/shared/homes/118623/bee_project/scoary/goslim_generic.obo"


# Set the working directory
# This is where the inputs will be located
setwd(workingDir)

# List of protein identifiers (tab-delimited with one identifier on each line)
protein_ids <- readLines("UniprotIdentifiers_input_small.txt")

# Initialize an empty list to store all GO terms
all_go_terms <- list()
# Parse each protein ID using the QuickGO API and return the proteins gene ontology IDs and terms
for (protein_id in protein_ids) {
  api_url <- paste0("https://www.ebi.ac.uk/QuickGO/services/annotation/search?geneProductId=", protein_id)
  
  response <- GET(api_url)
  
  if (http_type(response) == "application/json") {
    data <- fromJSON(content(response, "text"))
    go_terms <- data$results$goId
    all_go_terms <- c(all_go_terms, list(go_terms))
  } else {
    cat(paste("Failed to retrieve data for", protein_id, ". Status code:", http_status(response), "\n"))
  }
}

# Create a data frame with protein IDs and GO terms
result_data <- data.frame(
  Protein_ID = rep(protein_ids, sapply(all_go_terms, length)),
  GO_Term = unlist(all_go_terms)
)

# Create the output directory if it is missing
if (dir.exists(outputBaseDir)) {
  print(paste0(outputBaseDir, " ... already exists!"))
} else {
  dir.create(outputBaseDir)
}

setwd(outputBaseDir)
# Define the output TSV filename
tsv_filename <- "go_terms_for_multiple_protein_IDs.tsv"
# Write the data frame to a TSV file
write.table(x = result_data, file = tsv_filename, sep = "\t", quote = FALSE, row.names = FALSE)


# Section 2 - 
# >>>>>>>>>>
library(httr)
library(jsonlite)

# Get the Generic Slims Obo file
genericSlim = getOBOCollection(OboFileInput)

# myIds = unique(result_data$GO_Term)
# myCollection <- GOCollection(myIds)
# protAndGOIDsFile = tsv_filename
# inFileBase = basename(protAndGOIDsFile)
# protAndGOIDs = result_data


myIds = result_data$GO_Term
myCollection <- GOCollection(myIds)


# This should match the ontology used above.
# E.g. GOBPOFFSPRING or GOCCOFFSPRING
# GO.db::GOMFOFFSPRING
outputSlimsDir = paste0(outputBaseDir, "/GO_Slims")

setwd(outputSlimsDir)
# Function to get the three ontology categories
organiseDF = function(genericSlimsData, slimsCat) {
  inputDF = goSlim(myCollection, genericSlimsData, ontology = slimsCat)
  inputDF = as.data.frame(inputDF)
  inputDF$GOIDs = row.names(inputDF)
  inputDF = inputDF[ , c(4,3,1,2)]
  indexKeep = inputDF$Count != 0
  inputDF = inputDF[indexKeep,]
  row.names(inputDF) = NULL
  na.omit(inputDF)
  inputDF = inputDF[order(inputDF$Count, decreasing = TRUE), ]
  outName = paste0("GO_Slims_", slimsCat, ".tsv")
  write.table(x = inputDF, file = outName, quote = FALSE, row.names = FALSE, sep = "\t")
  return(inputDF)
}

slimBP = organiseDF(genericSlim, "BP")
slimCC = organiseDF(genericSlim, "CC")
slimMF = organiseDF(genericSlim, "MF")
