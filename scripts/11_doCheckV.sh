#!/bin/bash

# Directories
DATADIR=$LUSTRE/sergio/viroSeqs
OUTDIR=$LUSTRE/sergio/checkVBinsResults

#Create OUTDIR if it does not exist
if [ ! -d $OUTDIR ]; then mkdir -p $OUTDIR; fi

# Load necessary modules
module load cesga/2020 gcccore/system checkv/1.0.1

# Run it with error handling
set -e  # Exit immediately if a command exits with a non-zero status

# Run your application
checkv end_to_end ${DATADIR}/totalBinnedContigs.fa ${OUTDIR} \
-t $SLURM_CPUS_PER_TASK --remove_tmp

# Check if the job was successful
if [ $? -eq 0 ]; then
    echo "Job completed successfully."
else
    echo "Job failed." >&2
    exit 1
fi

# RUN => ./doCheckV.sh 
# Help => module spider checkv/1.0.1
