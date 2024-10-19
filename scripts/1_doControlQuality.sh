#!/bin/bash

# Load necessary modules
module load fastqc/0.12.1
module load multiqc/1.24.1-python-3.9.9

# Directories 
INPUTDIR=$LUSTRE/sergio/reads
OUTPUTDIR=$LUSTRE/sergio/QualityResults

# Create output directory if it doesn't exist
if [ ! -d ${OUTPUTDIR} ];then mkdir -p ${OUTPUTDIR};fi

# Run it with error handling
set -e  # Exit immediately if a command exits with a non-zero status

# Run your application
fastqc ${INPUTDIR}/*.fastq.gz -t $SLURM_CPUS_PER_TASK -o ${OUTPUTDIR}
cd ${OUTPUTDIR}
multiqc ${OUTPUTDIR}/.

# Check if the run was successful
if [ $? -eq 0 ]; then
    echo "Script completed successfully."
else
    echo "Script failed." >&2
    exit 1
fi

# Run => ./1_doQualityControl.sh
# Help 1 => module spider fastqc/0.12.1 
# Help 2 => module spider multiqc/1.24.1-python-3.9.9
