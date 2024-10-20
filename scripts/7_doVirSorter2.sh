#!/bin/bash

# Load necessary modules
module load cesga/system virsorter2/2.2.4

# Directories 
INPUTDIR=$LUSTRE/sergio/viroSeqs
OUTPUTDIR=$LUSTRE/sergio/VS2Results

# Create output directory if it doesn't exist
if [ ! -d ${OUTPUTDIR} ];then mkdir -p ${OUTPUTDIR};fi

# Run it with error handling
set -e  # Exit immediately if a command exits with a non-zero status

# Run your application
virsorter config --init-source --db-dir=$EBROOTVIRSORTER2/db

virsorter run -w ${OUTPUTDIR} \
-i  ${INPUTDIR}/total_filtered_contigs.fa \
-j  $SLURM_CPUS_PER_TASK \
--tmpdir ${OUTPUTDIR}/tmp \
--rm-tmpdir \
--include-groups dsDNAphage,NCLDV,RNA,ssDNA,lavidaviridae

# Check if the job was successful
if [ $? -eq 0 ]; then
    echo "Job completed successfully."
else
    echo "Job failed." >&2
    exit 1
fi

# RUN => ./7_doVirSorter2.sh
# HELP => module spider cesga/system virsorter2/2.2.4
