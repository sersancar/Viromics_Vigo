#!/bin/bash

# Load necessary modules
module load cesga/system miniconda3/22.11.1-1

# Activate environment
conda activate vRhyme

# Directories 
DATADIR=$LUSTRE/sergio/viroSeqs
READSDIR=$LUSTRE/sergio/filteredReads
OUTPUTDIR=$LUSTRE/sergio/vRhymeResults

# Run it with error handling
set -e  # Exit immediately if a command exits with a non-zero status

# Run your application
vRhyme -i ${DATADIR}/total_viral_contigs.fa \
-r ${READSDIR}/*.fastq \
-o ${OUTPUTDIR} \
--method composite \
-t $SLURM_CPUS_PER_TASK \
--iter 20 \
-l 2000 \
--bin_size 2 \
-m 1000 

# Check if the job was successful
if [ $? -eq 0 ]; then
    echo "Job completed successfully."
else
    echo "Job failed." >&2
    exit 1
fi

# Deactivate the environment
conda deactivate

# RUN => ./9_doVRhyme.sh
# HELP => vRhyme -h
