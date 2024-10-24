#!/bin/bash

# Load necessary modules
module load cesga/2020 gcccore/system megahit/1.2.9-python-3.9.9

# Directories 
OUTPUTDIR=$LUSTRE/sergio/MegahitResults
READSDIR=$LUSTRE/sergio/filteredReads

# Create output directory if it doesn't exist
if [ ! -d ${OUTPUTDIR} ];then mkdir -p ${OUTPUTDIR};fi

# Run it with error handling
set -e  # Exit immediately if a command exits with a non-zero status

# Run your application
megahit --presets meta-large \
-1 ${READSDIR}/$1_unmapped_1.fastq.gz \
-2 ${READSDIR}/$1_unmapped_2.fastq.gz \
-o ${OUTPUTDIR}/$1

# Check if the alignment was successful
if [ $? -eq 0 ]; then
    echo "Job completed successfully."
else
    echo "Job failed." >&2
    exit 1
fi

# Run => while read sample;do ./doMegahit.sh ${sample};done < samples.txt
# Help => module spider megahit/1.2.9-python-3.9.9

