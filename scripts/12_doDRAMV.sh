#!/bin/bash

# Directories
DATADIR=$LUSTRE/sergio/viroSeqs
OUTDIR=$LUSTRE/sergio/DRAMResults
DBDIR=/mnt/netapp2/bio_databases/cursocsic2024/DRAM_data/

# Load necessary modules
module load cesga/system miniconda3/22.11.1-1

# Avtivate conda environment
conda activate DRAM

# Run it with error handling
set -e  # Exit immediately if a command exits with a non-zero status

# Run your application
DRAM-v.py annotate \
--threads $SLURM_CPUS_PER_TASK \
-i ${DATADIR}/totalBinnedContigs.fa \
-o ${OUTDIR}

# Check if the job was successful
if [ $? -eq 0 ]; then
    echo "Job completed successfully."
else
    echo "Job failed." >&2
    exit 1
fi

# Deactivate the environment
conda deactivate

# RUN => ./doDRAMV.sh
HELP => DRAM-v.py -h
