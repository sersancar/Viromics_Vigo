#!/bin/bash

# Directories
DATADIR=$LUSTRE/sergio/viroSeqs
OUTDIR=$LUSTRE/sergio/iphopResults2
DBDIR=/mnt/netapp2/bio_databases/cursocsic2024/iphopDB/Aug_2023_pub_rw

# Create OUTDIR if it does not exist
if [ ! -d $OUTDIR ]; then mkdir -p $OUTDIR; fi

# Load necessary modules
module load cesga/system miniconda3/22.11.1-1

# Avtivate conda environment
conda activate iphop

# Run it with error handling
set -e  # Exit immediately if a command exits with a non-zero status

# Run your application
iphop predict --fa_file ${DATADIR}/totalBinnedContigs.fa \
--db_dir ${DBDIR} \
--out_dir ${OUTDIR} \
--num_threads $SLURM_CPUS_PER_TASK \
--min_score 80

# Check if the job was successful
if [ $? -eq 0 ]; then
    echo "Job completed successfully."
else
    echo "Job failed." >&2
    exit 1
fi

# Deactivate the environment
conda deactivate

# RUN => ./doIphop.sh
# HELP => iphop -h
