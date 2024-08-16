# Viromics_Vigo (IIM-CSIC)
This repo contains the material we will employ during the Viromics day (thursday, October 24: 9-14h).

During this session we will work with *Apostichopus japonicus* (sea cucumber), a non-model organism. But we are lucky. It's genome is already sequenced and deposited al the NCBI with Chromosome Assembly level (GCA_037975245.1: https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_037975245.1/).

<p align="center">
  <img src="https://github.com/user-attachments/assets/2c647b3c-b843-4e16-8d11-f3974e46fce5" alt="Prickly sea cucumber soup">
</p>

Our sea cucumber is not only an elegant echinoderm, but also a valuable delicacy, especially in China, Korea and Japan. Many tonnes of this sea cucumber are caught every year, and it is also farmed on a commercial scale. When farmed, sea cucumbers are fed a diet consisting mainly of algae and sometimes suffer from diseases related to eating disorders. These disorders reduce the growth of the sea cucumber and result in millionaire losses.

In this 'hands on' activity we will try to investigate the ecological role played by viruses in the gut microbiome of sea cucumbers. Viruses are known to limit the host population they parasitise and also drive the evolution of their hosts through horizontal gene transfer and the expression of viral auxiliary metabolic genes (AMGs). These AMGs are host genes that viruses carry in their genomes to enhance specific metabolic pathways, providing an evolutionary advantage to the hosts.

We will study the viruses we will found in the gut microbiome of a male and a female sea cucumbers. These metagenomes were published in https://doi.org/10.1016/j.aquaculture.2023.740125 and are deposited at the NCBI with SRR23999930 (https://www.ncbi.nlm.nih.gov/search/all/?term=SRR23999930) and SRR23999948 (https://www.ncbi.nlm.nih.gov/search/all/?term=SRR23999948) accesion numbers. To do so, we will follow the next steps:

  1. **Watch quality of the reads**. We will use **FastQC** () and **MultiQC** (). The first tool do the job for each file and the second one summarises the results.
  2.  **Delete non-paired and low quality reads**. To do so we will use **Trimmomatic** ().
  3. **Delete possible contaminated reads**. We will eliminate the reads that belong to the sea cucumber to only employ in downstream analisys those that are microbial ones. To achive this, we will first build a index with *A. Japonicus* genome to then map all previously filtered reads to it. We will use the unmapped reads in further analysis.
  4. **Assembling**. We will get our beloved microbial contigs using MEGAHIT ().
  5. **Viral Discovery**. Remember! Our reads came from a metagenome, so they will belong principally to *Bacteria* and *Archaea*. We will nedd to find the 'needle in the haystack'. We will look for the viral contigs within the total contigs obtained employingg VirSorter2 (), VIBRANT () and DeepVirFinder ().    
