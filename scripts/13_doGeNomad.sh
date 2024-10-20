#!/bin/bash

# Directories
DATADIR=$LUSTRE/sergio/viroSeqs
OUTDIR=$LUSTRE/sergio/geNomadResults
DBDIR=$HOME/genomad_db

# Create OUTDIR if it does not exist
if [ ! -d $OUTDIR ]; then mkdir -p $OUTDIR; fi

# Load necessary modules
module load cesga/system miniconda3/22.11.1-1

# Avtivate conda environment
conda activate genomad

# Run it with error handling
set -e  # Exit immediately if a command exits with a non-zero status

# Run your application
genomad end-to-end \
--cleanup \
--threads $SLURM_CPUS_PER_TASK \
${DATADIR}/totalBinnedContigs.fa ${OUTDIR} ${DBDIR}

# Check if the job was successful
if [ $? -eq 0 ]; then
    echo "Job completed successfully."
else
    echo "Job failed." >&2
    exit 1
fi

# Deactivate the environment
conda deactivate

# RUN =>  ./doGenomad.sh 
# HELP => genomad -h
