#!/usr/bin/R Rscript

# Prepare R to input arguments with the script
args = commandArgs(trailingOnly=TRUE)

library("seqinr")

# Path to Roary Fasta output
  # pathToRoaryFasta = "/shared/homes/118623/bee_project/scoary/scoary_pan_genome_reference.fa"
  # outputDir = "/roary_toScoary_Fasta"
  # pathToFilteredScoaryGenes = "/Users/paulworden/Library/CloudStorage/OneDrive-DPIE/General_and_Overall/Journal_papers/Bee_Brood_Diseases/AFB/Sept_2023_Draft/Panaroo_Pan_Genome/scoary/scoary_test_output/scoary_filtered/ERIC_Type_I_or_II_04_10_2023_0918_genes.txt"
pathToRoaryFasta = args[1]
outputDir = args[2]
pathToFilteredScoaryGenes = args[3]

fastaFile = read.fasta(file = pathToRoaryFasta, seqtype = "DNA", as.string = TRUE, set.attributes = FALSE, whole.header = TRUE)
fastaHeaderText = names(fastaFile)


# Path to genes from scoary filtered output
geneList = readLines(pathToFilteredScoaryGenes)

fastaSubset = fastaFile[names(fastaFile) %in% geneList]

if (dir.exists(outputDir)) {
  print(paste0(outputDir, " ... already exists!"))
} else {
  dir.create(outputDir)
}

write.fasta(fastaSubset, names = names(fastaSubset), file.out = paste0(outputDir, "/", "scoaryGeneList.fasta"))


