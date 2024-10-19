#!/bin/bash

# Load necessary modules
module load cesga/2020 trimmomatic/0.39 

# Directories 
INPUTDIR=$LUSTRE/sergio/reads
OUTPUTDIR=$LUSTRE/sergio/reads

# Create output directory if it doesn't exist
if [ ! -d ${OUTPUTDIR} ];then mkdir -p ${OUTPUTDIR};fi

# Run it with error handling
set -e  # Exit immediately if a command exits with a non-zero status

# Run your application
java -jar $CLASSPATH PE -summary ${OUTPUTDIR}/statsSummary_$1 -threads 36 \
${INPUTDIR}/$1_1.fastq.gz ${INPUTDIR}/$1_2.fastq.gz \
${OUTPUTDIR}/$1_paired_1.fastq.gz ${OUTPUTDIR}/$1_unpaired_1.fastq.gz \
${OUTPUTDIR}/$1_paired_2.fastq.gz ${OUTPUTDIR}/$1_unpaired_2.fastq.gz \
LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:50

# Check if the run was successful
if [ $? -eq 0 ]; then
    echo "Script completed successfully."
else
    echo "Script failed." >&2
    exit 1
fi

#while read sample;do sbatch 2_doTrimmomatic.sh ${sample};done<samples.txt
#help => module spider trimmomatic/0.39
