#!/bin/bash -l

#SBATCH -p high
#SBATCH -D /group/weimergrp/smh/MARS
#SBATCH -o /group/weimergrp/smh/MARS/slurm-log/MARS_salmon_human-stdout-%j.txt
#SBATCH -e /group/weimergrp/smh/MARS/slurm-log/MARS_salmon_human-stderr-%j.txt
#SBATCH -J MARS_salmon_human
#SBATCH -N 1
#SBATCH -c 12
#SBATCH --mem 32000
#SBATCH --array 73
#SBATCH -t 96:00:00
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=smhigdon@ucdavis.edu

# Name: MARS_salmon_human.sh
# Created by: Shawn Higdon
# creation date: December 3, 2018
# An array script to quantify human transcripts within fastq reads that survived after using kraken2 to isolate reads classified as human against the GRch38 human genome. Reads are quantified using the ensembl transcriptome (all CDS and ncRNA sequences for GRCh38 available on Dec 3, 2018).

# Load environment

source activate rnaseq

# Define Variable

OUTPUT_FOLDER=analysis # folder for all output
mkdir -p $OUTPUT_FOLDER

SEEDFILE=input_files/MARS_salmon_human_R1_inputs.txt # the list of human PE_1 files that will be processed (absolute path), 1 per line.

SEED=$(cat $SEEDFILE | head -n $SLURM_ARRAY_TASK_ID | tail -n 1)

SEEDFILE2=input_files/MARS_salmon_human_R2_inputs.txt # the list of human PE_2 files that will be processed (absolute path), 1 per line.

SEED2=$(cat $SEEDFILE2 | head -n $SLURM_ARRAY_TASK_ID | tail -n 1)

bname=`basename $SEED`
bname=`echo $bname | cut -d. -f1`

INDEX=/home/smhigdon/mnt/salmon/GRCh38_ensembl_index

SALMON_FOLDER=$OUTPUT_FOLDER/salmon_human_ensembl
mkdir -p $SALMON_FOLDER

# Quantify transcripts using salmon 

salmon quant \
	-i $INDEX \
	-l A \
	-1 ${SEED} \
	-2 ${SEED2} \
	-p 12 \
	--gcBias \
	-o $SALMON_FOLDER/${bname}

hostname
export OMP_NUM_THREADS=$SLURM_NTASKS
module load benchmarks
stream
