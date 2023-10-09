#!/bin/bash

# #PBS -l ncpus=32
# #PBS -l mem=128GB
# #PBS -l walltime=48:00:00

source /shared/homes/118623/miniconda3/etc/profile.d/conda.sh # Path to conda
conda activate blobtools2
# ----------------------------------------------------------------------
# USER INPUT
        # inputFileAndPath="/shared/homes/118623/bee_project/scoary/scoary_test_output/scoary_filtered/roary_toScoary_Fasta/subsetScoaryGeneList.fasta"
        # diamondOutDirPath="/shared/homes/118623/bee_project/scoary/scoary_test_output/scoary_filtered/roary_toScoary_Fasta/diamond_db_result"
        # diamondBlastxDatabase="/shared/homes/118623/blobtools_db/uniprot/reference_proteomes.dmnd"

inputFileAndPath=$1
diamondOutDirPath=$2
# Path to diamond database
diamondBlastxDatabase=$3
# ----------------------------------------------------------------------
inputPath=${diamondOutDirPath%/*}
baseNameOut=${inputPath##*/}

if [ -e $diamondOutDirPath ]; then echo "Folder exists!"; else mkdir $diamondOutDirPath; echo "Creating folder: $diamondOutDirPath"; fi

# Run diamond align
diamondOutFile=$diamondOutDirPath/$baseNameOut"_diamond.out"
diamond blastx --query $inputFileAndPath \
        --db $diamondBlastxDatabase \
        --outfmt 6 qseqid qstart qend sseqid sstart send staxids pident length mismatch gapopen evalue bitscore \
        --sensitive \
        --max-target-seqs 1 \
        --evalue 1e-15 \
        --tmpdir "/shared/homes/118623/blobtools_db/diamond_temp" \
        --threads 8 \
        --out $diamondOutFile
