#!/bin/bash

# Load necessary modules
module load  cesga/2020 gcccore/system bowtie2/2.4.4 samtools/1.19

# Directories 
REFERENCEDIR=$LUSTRE/sergio/AJaponicus
READSDIR=$LUSTRE/sergio/reads
OUTPUTDIR=$LUSTRE/sergio/filteredReads

# Create output directory if it doesn't exist
if [ ! -d ${OUTPUTDIR} ];then mkdir -p ${OUTPUTDIR};fi

# Run it with error handling
set -e  # Exit immediately if a command exits with a non-zero status

# Run your application
bowtie2 --threads $SLURM_CPUS_PER_TASK \
-x ${REFERENCEDIR}/A_Japonicus_index \
-1 ${READSDIR}/$1_paired_1.fastq.gz \
-2 ${READSDIR}/$1_paired_2.fastq.gz \
--un-conc-gz ${OUTPUTDIR}/$1_unmapped_%.fastq.gz | \
samtools view -bS - > ${OUTPUTDIR}/$1_align.bam

# Check if the alignment was successful
if [ $? -eq 0 ]; then
    echo "Job completed successfully."
else
    echo "Job failed." >&2
    exit 1
fi

# Run => while read sample;do ./4_doBowtie2_2.sh ${sample};done<samples.txt
# Help 1 => module spider bowtie2/2.4.4
# Help 2 => module spider samtools/1.19
