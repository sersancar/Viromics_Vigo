#!/bin/bash

# Load necessary modules
module load cesga/2020 vibrant/v1.2.1

# Directories 
INPUTDIR=$LUSTRE/sergio/viroSeqs
OUTPUTDIR=$LUSTRE/sergio/VIBRANTResults/
VIBRANTDIR=/opt/cesga/2020/software/Core/vibrant/v1.2.1

# Create output directory if it doesn't exist
if [ ! -d ${OUTPUTDIR} ];then mkdir -p ${OUTPUTDIR};fi

# Run it with error handling
set -e  # Exit immediately if a command exits with a non-zero status

# Run your application

VIBRANT_run.py \
-f nucl \
-i  ${INPUTDIR}/total_filtered_contigs.fa \
-t  $SLURM_CPUS_PER_TASK \
-folder ${OUTPUTDIR} \
-d ${VIBRANTDIR}/databases \
-m ${VIBRANTDIR}/files


# Check if the job was successful
if [ $? -eq 0 ]; then
    echo "Job completed successfully."
else
    echo "Job failed." >&2
    exit 1
fi

# RUN => ./6_doVIBRANT.sh
# Help => module spider vibrant/v1.2.1
