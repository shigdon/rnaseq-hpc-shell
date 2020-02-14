#!/bin/bash -l

#SBATCH -p high
#SBATCH -D /group/weimergrp/smh/MARS
#SBATCH -o /group/weimergrp/smh/MARS/slurm-log/MARS_bracken2-stdout-%j.txt
#SBATCH -e /group/weimergrp/smh/MARS/slurm-log/MARS_bracken2-stderr-%j.txt
#SBATCH -J MARS_bracken
#SBATCH -N 1
#SBATCH -n 4
#SBATCH --array 54
#SBATCH -t 48:00:00
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=smhigdon@ucdavis.edu

# Name: MARS_bracken.sh
# Created by: Shawn Higdon
# creation date: June 18, 2019
# An array script to estimate taxonomic abundance from kraken2 reports.

# Load environment

source activate bracken

# Define Variable

OUTPUT_FOLDER=analysis # folder for all output
mkdir -p $OUTPUT_FOLDER

SEEDFILE=input_files/MARS_bracken_inputs.txt # the list of kraken2 report files that will be processed (absolute path), 1 per line.

SEED=$(cat $SEEDFILE | head -n $SLURM_ARRAY_TASK_ID | tail -n 1)

bname=`basename $SEED`
bname=`echo $bname | cut -d. -f1`

SAMPLE_FOLDER=$OUTPUT_FOLDER/${bname}
mkdir -p $SAMPLE_FOLDER

DB=/home/smhigdon/mnt/krakenDB/kraken2_microbes/database150mers.kmer_distrib # Refseq Complete Bacteria, Archaea, Viral, UniVec_CORE in bracken flavor with readlength set to 150 and k-size set to 35 for kraken2 default k-size.

KRAKEN2_FOLDER=$SAMPLE_FOLDER/kraken2
mkdir -p $KRAKEN2_FOLDER

MICROBE_FOLDER=$KRAKEN2_FOLDER/microbes
mkdir -p $MICROBE_FOLDER

BRACKEN_FOLDER=$MICROBE_FOLDER/bracken
mkdir -p $BRACKEN_FOLDER

# Estimate microbial abundances at different taxonomic levels using Bracken 2

## Family Level
est_abundance.py \
	-i $SEED \
	-k $DB \
	-l F \
	-t 5 \
	-o ${BRACKEN_FOLDER}/${bname}_family.bracken

## Genus Level
est_abundance.py \
        -i $SEED \
	-k $DB \
        -l G \
        -t 5 \
        -o ${BRACKEN_FOLDER}/${bname}_genus.bracken

## Species Level
est_abundance.py \
        -i $SEED \
	-k $DB \
        -l S \
        -t 5 \
        -o ${BRACKEN_FOLDER}/${bname}_species.bracken 

hostname
export OMP_NUM_THREADS=$SLURM_NTASKS
module load benchmarks
stream
