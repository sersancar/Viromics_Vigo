## Viromics (IIM-CSIC)
# This repo contains the material we will employ during the Viromics day (thursday, October 24: 9-14h) within the course "Omics tools in aquaculture" at the IIM in Vigo .

During this session we will work with *Apostichopus japonicus* (sea cucumber), a non-model organism. But we are lucky. Its genome is already sequenced and deposited al the NCBI with Chromosome Assembly level (GCA_037975245.1: https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_037975245.1/).

<p align="center">
  <img src="https://github.com/user-attachments/assets/2c647b3c-b843-4e16-8d11-f3974e46fce5" alt="Prickly sea cucumber soup">
</p>

Our sea cucumber is not only an elegant echinoderm, but also a valuable delicacy, especially in China, Korea and Japan. Many tonnes of this sea cucumber are caught every year, and it is also farmed on a commercial scale. When cultivated, sea cucumbers are mainly fed on a diet consisting of seaweeds and sometimes they suffer from diseases related to eating disorders. These disorders reduce the growth of the sea cucumber and result in millionaire losses.

In this 'hands on' activity we will try to investigate the ecological role played by viruses in the gut microbiome of sea cucumbers. Viruses are known to limit the host population they parasitise and also drive the evolution of their hosts through horizontal gene transfer and the expression of viral auxiliary metabolic genes (AMGs). These AMGs are host genes that viruses carry in their genomes to enhance specific metabolic pathways, providing an evolutionary advantage to the hosts and also to the smart replicants  that  viruses are.

We will study the viruses we will found in the gut microbiome of a male and a female sea cucumbers. These metagenomes were published in https://doi.org/10.1016/j.aquaculture.2023.740125 and are deposited at the NCBI with SRR23999930 (https://www.ncbi.nlm.nih.gov/search/all/?term=SRR23999930) and SRR23999948 (https://www.ncbi.nlm.nih.gov/search/all/?term=SRR23999948) accesion numbers. To do so, we will follow the next steps:

  1. **Control the quality of the reads**. We will use **FastQC** (https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) and **MultiQC** (https://github.com/MultiQC/MultiQC). The first tool do the job for each file and the second one summarises the results.
  2. **Delete non-paired and low quality reads**. To do so we will use **Trimmomatic** (https://github.com/usadellab/Trimmomatic).
  3. **Delete possible contaminated reads**. We will eliminate the reads that belong to the sea cucumber to only employ in downstream analisys those that are microbial ones. To achive this, we will first build a index with *A. Japonicus* genome to then map all previously filtered reads to it. We will use the unmapped reads in further analysis. To achive this, we will use the classic aligner **Bowtie2** (https://github.com/BenLangmead/bowtie2). 
  4. **Assembling**. We will get our beloved microbial contigs using **MEGAHIT** (https://github.com/voutcn/megahit).
  5. **Viral Discovery**. Remember! Our reads came from a metagenome, so they will belong principally to *Bacteria* and *Archaea*. We will need to find the 'needle in the haystack'. We will look for the viral contigs within the total contigs obtained employingg **VirSorter2** (https://github.com/jiarong/VirSorter2), **VIBRANT** (https://github.com/AnantharamanLab/VIBRANT) and **DeepVirFinder** (https://github.com/jessieren/DeepVirFinder). We will put all the putative viral contig obtained with each method together to continue the analisys.
  6. **Binning**. We will employ **vRhyme** (https://github.com/AnantharamanLab/vRhyme), a virus-specialised clustering tool to group all the viral contigs that belongs to the same operational taxomomic unit (OTU).
  7.  **Viral Contigs quantification**. We will use **CoverM** (https://github.com/wwood/CoverM).
  8.  **Completeness and contamination** of the contigs using **checkV** (https://bitbucket.org/berkeleylab/checkv/src/master/). 
  9. **Taxonomic annotanion** of the binned contigs using **geNomad** (https://github.com/apcamargo/genomad).
  10. **Host prediction** of the binned contigs with **iPHoP** (https://bitbucket.org/srouxjgi/iphop/src/main/).
  11. **Viral Proteins Annotation** of the binned contigs. We will use **DRAM-V** (https://github.com/WrightonLabCSU/DRAM) to perform this task.
  12. **Data Analysis**. We will use **R** (https://www.r-project.org/) within **RStudio** (https://posit.co/products/open-source/rstudio/) to get some insights into the ecological role that viruses play in the gut microbial communitie of sea cubumbers.

All code deposited in this repo is intended to be run in the HPC cluster Finisterrae III hosted by CESGA (Galicia Supercomputing Center). The CESGA Technical Documentation, incluiding Finisterrae III User Guide, can be consulted at https://cesga-docs.gitlab.io/index.html .We will use the cluster in a dedicated interactive way. To do so we will write in the cluster console: compute -c n_cores --mem mG, where n_cores is the number of cores and m the RAM memory in GB demanded to Finisterrae III. In these nodes the maximum resources available are 64 cores and 247GB of RAM memory for a maximum of 8 hours. Enough for our purposes! We recomend mounting a machine with at least 36 cores and 100GB of RAM.

**So let's start!**

First of all let's check that all the files needed in this session are stored where they are supposed to be:

```bash
ls -lh $LUSTRE/sergio/AJaponicus
ls -lh $LUSTRE/sergio/reads
```

AJaponicus directory must contains the genome of our sea cucumber (A_Japonicus_genome.fna.gz) and reads must contains the reads of the metagenomes (A_Japonicus_female/male_1/2.fastq.gz). For security reasons we will change the name of $LUSTRE/sergio and will move these directories just in case something fails during this practical session. The remaining subdirectories within $LUSTRE/sergio contain the results of the execution of all scripts.

```bash
mv $LUSTRE/sergio $LUSTRE/sergio2
mkdir $LUSTRE/sergio
mv $LUSTRE/sergio2/AJaponicus $LUSTRE/sergio
mv $LUSTRE/sergio2/reads $LUSTRE/sergio
```

In our home directory in Finisterrae III we will clone this repository:

```bash
cd $HOME
git clone https://github.com/sersancar/Viromics_Vigo.git
```
After this, we will go to the directory where all scripts needed in this session are stored:

```bash
cd Viromics_Vigo/scripts
```

To execute all scripts in this directory each one needs the execution permission, so let's do:

```bash
chmod +x *.sh
```

To run each script we will do:

```bash
compute -c 36 --mem 100G
./script_name.sh
```

Each script will read the input files and write the output files to a directory specified by the script. At the end of each script we will find the command to execute it and also a command to get some help about the executed program.

Run the scripts 1 to 5. After their completion, we need to rename and move the assembled contigs by executing:

```bash
mkdir $LUSTRE/sergio/viroSeqs
mv $LUSTRE/sergio/MegahitResults/A_japonicus_female/final.contigs.fa $LUSTRE/sergio/viroSeqs/A_japonicus_female_contigs.fa
mv $LUSTRE/sergio/MegahitResults/A_japonicus_male/final.contigs.fa $LUSTRE/sergio/viroSeqs/A_japonicus_male_contigs.fa
```

In order to search for the viral contigs hidden in the total amount of contigs, we will concatenate all contigs in the same file. To identify latter on the source of the each contig we will add a prefix to each contig: "A_japonicus_female_" for female contigs and "A_japonicus_male_" for male ones. Also we will remove small contigs to don't waste time in not very meaningfull contigs. Let's do this in a few commands with a little help of seqkit (https://bioinf.shenwei.me/seqkit/): 

```bash
module load seqkit/2.1.0
seqkit seq -m 1000  $LUSTRE/sergio/viroSeqs/A_japonicus_female.fa | awk '/^>/ {print ">A_japonicus_female_" substr($1, 2); next} {print}' > $LUSTRE/sergio/viroSeqs/A_japonicus_female_filtered_contigs.fa.gz
seqkit seq -m 1000  $LUSTRE/viroSeqs/A_japonicus_male.fa | awk '/^>/ {print ">A_japonicus_male_" substr($1, 2); next} {print}' > $LUSTRE/sergio/viroSeqs/A_japonicus_male_filtered_contigs.fa
cat $LUSTRE/sergio/viroSeqs/*_filtered_*.fa > $LUSTRE/sergio/viroSeqs/total_filtered_contigs.fa
module purge
```

Now we now can continue running scripts 6 to 8 which perform the search for viral sequences within the total_filtered_contigs.fa fasta file. Once we are here, we need to put together all the contigs identified as viral. To achive this, we will firstly gather all viral contig identifiers obtained with each virus discovery tool:

```bash
module load seqkit/2.1.0
grep "||full" $LUSTRE/sergio/VS2VirResults/final-viral-score.tsv | cut -d'|' -f1 > VS2Virs.txt
awk '$3>=0.99 && $4<=0.01{print $1}' $LUSTRE/sergio/DVFVirResults/total_filtered_contigs.fa.gz_gt1bp_dvfpred.txt > DVFVirs.txt
seqkit seq -n -i $LUSTRE/sergio/VIBRANTResults/VIBRANT_total_filtered_contigs/VIBRANT_phages_total_filtered_contigs/total_filtered_contigs.phages_combined.fna > VIBRANTVirs.txt
cat *Virs.txt > total_viral_contigs.txt
```

Now we can create a fasta file containing all our viral contigs using the text file with the viral identifiers and the fasta file with all contigs:

```bash
seqkit grep -f total_viral_contigs.txt -i $LUSTRE/sergio/viroSeqs/total_filtered_contigs.fa -o $LUSTRE/sergio/viroSeqs/total_viral_contigs.fa
module purge
```

The next steep will be try to cluster all the viral contigs in groups. Each bin (cluster) will contain contigs taxonomically related that will be our Operational Taxonomic Units (OTUs). We will perform this task executing the script 9. This script run the program and produce bins with at least 2 members and 2Kbp of contig length. We will use also the composite dereplication method. This dereplication method will produce a new merged contig with those contigs that overlap. 

To follow the analysis we will keep the binned conting and also the non binned ones (singletons) using the shell:

```bash
module load seqkit/2.1.0
seqkit seq -n $LUSTRE/sergio/vRhymeResults/vRhyme_best_bins_fasta/*.fasta | awk -F'__' '{print $2}' | sort > binnedContigs.txt
cat $LUSTRE/sergio/vRhymeResults/vRhyme_dereplication/vRhyme_derep_composited-list_totalVirs.txt | sort > composited.txt
grep -v "composite" binnedContigs.txt > binnedContigs2.txt
cat composited.txt binnedContigs2.txt > binnedContigs3.txt
comm -23 totalContigs.txt binnedContigs3.txt > nonBinnedContigs.txt
seqkit grep -f nonBinnedContigs.txt -i $LUSTRE/sergio/viroSeqs/total_viral_contigs.fa | seqkit seq -m 2000 > $LUSTRE/sergio/viroSeqs/nonBinnedContigs.fa
cat $LUSTRE/sergio/vRhymeResults/vRhyme_best_bins_fasta/*.fasta > $LUSTRE/sergio/viroSeqs/binnedContigs.fa
cat $LUSTRE/sergio/viroSeqs/nonBinnedContigs.fa $LUSTRE/sergio/viroSeqs/binnedContigs.fa > $LUSTRE/sergio/viroSeqs/totalBinnedContigs.fa
module purge
```

The fasta file totalBinnedContigs.fa.gz will contain our definitive set of viral sequencies detected in this study. Using it as input we will run the scripts 10 to 14 to respectively quantify the abundance of the contigs in the samples, check for the completeness and contamination, annotate the proteins getting insights in the functionality, try to find the taxonomy of the contigs and also the possible hosts.

At this point we have all the information needed to perform the final data analysis in RStudio using script 15. Before this, we will collect all tables in a directory in orther to simplify the paths:

```bash
mkdir $LUSTRE/sergio/finalTables
mv $HOME/Viromics_Vigo/metabolism_vigo.tsv $LUSTRE/sergio/finalTables
cp $LUSTRE/sergio/contigsCounts/*.tsv $LUSTRE/sergio/finalTables
cp $LUSTRE/sergio/checkVBinsResults/quality_summary.tsv $LUSTRE/sergio/finalTables
cp $LUSTRE/sergio/DRAMResults/annotations.tsv $LUSTRE/sergio/finalTables
cp $LUSTRE/sergio/geNomadResults/totalBinnedContigs_summary/*_summary.tsv $LUSTRE/sergio/finalTables
cp $LUSTRE/sergio/iphopResults/*_m80.csv $LUSTRE/sergio/finalTables
```

We also need the finalTables directory in the machine we are going to perform the data analysis, so in a terminal in our laptop we can execute:

```bash
scp -r USER@ft3.cesga.es:LUSTRE/sergio/finalTables DESTINATION
```

Where user is your USER in Finisterrae III, LUSTRE is your complete path to the LUSTRE directory in Finisterrae III and DESTINATION is the complete path to the local directory destination. So to run the script 15 with RStudio, we can copy/paste its content directly from this repo or copy the file using scp:

```bash
scp -r USER@ft3.cesga.es:HOMEViromics_Vigo/scripts/15_R_script.R DESTINATION
```
In this case HOME is the complete path to your HOME in Finisterrae III. 

The first lines of script 15 deal with the installation and load of the required packages to perform the data analysis. Specifically these packages are tidyverse (https://www.tidyverse.org/), vegan (https://cran.r-project.org/web/packages/vegan/), directlabels (https://cran.r-project.org/web/packages/directlabels), ggforce (https://cran.r-project.org/web/packages/ggforce) and VennDiagram (https://cran.r-project.org/web/packages/VennDiagram).
