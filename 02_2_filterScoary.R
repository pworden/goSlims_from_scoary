#!/usr/bin/R Rscript

# Prepare R to input arguments with the script
args = commandArgs(trailingOnly=TRUE)

# Path to Scoary's CSV output
  # pathToScoaryAnalysis = "/shared/homes/118623/bee_project/scoary/scoary_output/ERIC_Type_I_or_II_07_10_2023_1703.results.csv"
pathToScoaryAnalysis = args[1]
  # p_value = "5.48575705636e-180"
p_value = args[2]
p_value = as.numeric(p_value)
inputDir = dirname(pathToScoaryAnalysis)
inputFileName = basename(pathToScoaryAnalysis)
outputTableBaseName = gsub(".results.csv", "", inputFileName)
# Output path
scoaryOutputFilteredDirPath = args[3]

outputPathAndTablename = paste0(scoaryOutputFilteredDirPath, "/", outputTableBaseName, "_filtered.csv")
outputPathAndGeneNames = paste0(scoaryOutputFilteredDirPath, "/", outputTableBaseName, "_genes.txt")

if (dir.exists(scoaryOutputFilteredDirPath)) {
  print(paste0(scoaryOutputFilteredDirPath, " ... already exists!"))
} else {
  dir.create(scoaryOutputFilteredDirPath)
}

# Read in the CSV table of scoary output
scoaryOutputTable = read.csv(file = pathToScoaryAnalysis, header = TRUE, stringsAsFactors = TRUE, check.names = FALSE)
# Filter based on the column 'Naive_p'

scoaryOutputTableFiltered = scoaryOutputTable[scoaryOutputTable$Naive_p <= p_value,]
# Write the filtered output
write.csv(x = scoaryOutputTableFiltered,file = outputPathAndTablename, row.names = FALSE)
write.table(x = scoaryOutputTableFiltered["Gene"], file = outputPathAndGeneNames, col.names = FALSE, row.names = FALSE, quote = FALSE)
