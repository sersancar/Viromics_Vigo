#!/bin/bash

# Load necessary modules
module load cesga/system miniconda3/22.11.1-1

# Activate the environment
conda activate coverm

# Directories
BINSDIR=$LUSTRE/sergio/viroSeqs
READSDIR=$LUSTRE/sergio/filteredReads
OUTDIR=$LUSTRE/sergio/contigsCounts
TMPDIR=$LUSTRE/sergio/tmp

# Create OUTDIR and TMPDIR if it does not exist
if [ ! -d ${TMPDIR} ];then mkdir -p ${TMPDIR};fi
if [ ! -d ${OUTDIR} ];then mkdir -p ${OUTDIR};fi

# Run it with error handling
set -e  # Exit immediately if a command exits with a non-zero status

# Run your application
while read sample
do
coverm contig -t $SLURM_CPUS_PER_TASK \
-1 ${READSDIR}/${sample}_unmapped_1.fastq \
-2 ${READSDIR}/${sample}_unmapped_1.fastq \
-r ${BINSDIR}/totalBinnedContigs.fa \
-m mean count length rpkm tpm \
-o ${OUTDIR}/${sample}_coverage.tsv
done < samples.txt

# Delete TMPDIR
rm -Rf $LUSTRE/sergio/tmp

# Deactivate the environment
conda deactivate

# RUN => doCoverM.sh
# Help => coverm -h
