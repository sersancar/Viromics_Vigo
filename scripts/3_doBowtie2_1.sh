#!/bin/bash

# Load necessary modules
module load cesga/2020 bowtie2/2.4.4

# Directories 
INPUTDIR=$LUSTRE/sergio/AJaponicus
OUTPUTDIR=$LUSTRE/sergio/AJaponicus

# Create output directory if it doesn't exist
if [ ! -d ${OUTPUTDIR} ];then mkdir -p ${OUTPUTDIR};fi

# Run it with error handling
set -e  # Exit immediately if a command exits with a non-zero status

# Run your application
bowtie2-build --threads $SLURM_CPUS_PER_TASK \
${INPUTDIR}/A_Japonicus_genome.fna.gz \
${OUTPUTDIR}/A_Japonicus_index

# Check if the run was successful
if [ $? -eq 0 ]; then
    echo "Script completed successfully."
else
    echo "Script failed." >&2
    exit 1
fi

# Run => ./3_doBowtie2_1.sh
# Help => module spider bowtie2/2.4.4
