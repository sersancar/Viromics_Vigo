#!/bin/bash

# Load necessary modules
module load cesga/2020 miniconda3/22.11.1-1

# Activate environment
conda activate dvf

# Export the path to Theano working directory
export THEANO_FLAGS=base_compiledir=$LUSTRE/sergio/.theano

# Delete the THEANO_FLAGS directory content
rm -rf $LUSTRE/sergio/.theano/*

# Directories 
INPUTDIR=$LUSTRE/sergio/MegahitResults
OUTPUTDIR=$LUSTRE/sergio/DVFResults2
DVFDIR=$HOME/DeepVirFinder

# Create output directory if it doesn't exist
if [ ! -d ${OUTPUTDIR} ];then mkdir -p ${OUTPUTDIR};fi

# Run it with error handling
set -e  # Exit immediately if a command exits with a non-zero status

# Run your application

python ${DVFDIR}/dvf.py \
-i ${INPUTDIR}/total_filtered_contigs.fa \
-c $SLURM_CPUS_PER_TASK \
-o ${OUTPUTDIR}

# Check if the job was successful
if [ $? -eq 0 ]; then
    echo "Job completed successfully."
else
    echo "Job failed." >&2
    exit 1
fi

# Deactivate environment 
conda deactivate

# RUN => ./8_doDeepVirFinder.sh
# HELP => 

