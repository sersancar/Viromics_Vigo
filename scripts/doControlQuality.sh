#!/bin/bash

# Load necessary modules
module load fastqc/0.12.1
module load multiqc/1.24.1-python-3.9.9

# Directories 
INPUTDIR=$LUSTRE/reads
OUTPUTDIR=$LUSTRE/QualityResults

# Create output directory if it doesn't exist
if [ ! -d ${OUTPUTDIR} ];then mkdir -p ${OUTPUTDIR};fi

# Run your application
fastqc ${INPUTDIR}/*.fastq.gz -t $SLURM_CPUS_PER_TASK -o ${OUTPUTDIR}
cd ${OUTPUTDIR}
multiqc ${OUTPUTDIR}/.
cd $HOME/Viromics_Vigo/scripts

# Run => ./doQualityControl.sh
# Help 1 => module spider fastqc/0.12.1 
# Help 2 => module spider multiqc/1.24.1-python-3.9.9
