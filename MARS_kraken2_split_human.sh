#!/bin/bash -l

#SBATCH -p high
#SBATCH -D /group/weimergrp/smh/MARS
#SBATCH -o /group/weimergrp/smh/MARS/slurm-log/MARS_kraken2_split-stdout-%j.txt
#SBATCH -e /group/weimergrp/smh/MARS/slurm-log/MARS_kraken2_split-stderr-%j.txt
#SBATCH -J MARS_krak2_split
#SBATCH -N 1 
#SBATCH -n 24 
#SBATCH --mem 32000
#SBATCH --array 54
#SBATCH -t 72:00:00
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=smhigdon@ucdavis.edu

# Name: MARS_kraken2_split_human.sh
# Created by: Shawn Higdon
# creation date: June 17, 2019
# An array script to split fastq reads into human and microbial bins by using kraken2 to classify against the human genome.

# Load environment

source activate kraken2

# Define Variable

OUTPUT_FOLDER=analysis # folder for all output
mkdir -p $OUTPUT_FOLDER

SEEDFILE=input_files/MARS_kraken2_split_R1_input.txt # the list of trimmed PE_1 files that will be processed (absolute path), 1 per line.

SEED=$(cat $SEEDFILE | head -n $SLURM_ARRAY_TASK_ID | tail -n 1)

SEEDFILE2=input_files/MARS_kraken2_split_R2_input.txt # the list of trimmed PE_2 files that will be processed (absolute path), 1 per line.

SEED2=$(cat $SEEDFILE2 | head -n $SLURM_ARRAY_TASK_ID | tail -n 1)

bname=`basename $SEED`
bname=`echo $bname | cut -d. -f1`

SAMPLE_FOLDER=$OUTPUT_FOLDER/${bname}
mkdir -p $SAMPLE_FOLDER

DB=/home/smhigdon/mnt/krakenDB/kraken2_human

KRAKEN2_FOLDER=$SAMPLE_FOLDER/kraken2
mkdir -p $KRAKEN2_FOLDER

# Split human reads from microbial reads using Kraken2 

kraken2 \
	--threads 24 \
	--gzip-compressed \
	--paired \
	--db $DB \
	--unclassified-out $KRAKEN2_FOLDER/${bname}.not_human#.fq \
	--classified-out $KRAKEN2_FOLDER/${bname}.human#.fq \
	--output $KRAKEN2_FOLDER/${bname}.human_split.tsv \
	$SEED \
	$SEED2

# Gzip compress kraken2 output files

pigz -5 -v -p 24 $KRAKEN2_FOLDER/${bname}.not_human_1.fq
pigz -5 -v -p 24 $KRAKEN2_FOLDER/${bname}.not_human_2.fq
pigz -5 -v -p 24 $KRAKEN2_FOLDER/${bname}.human_1.fq
pigz -5 -v -p 24 $KRAKEN2_FOLDER/${bname}.human_2.fq
pigz -5 -v -p 24 $KRAKEN2_FOLDER/${bname}.human_split.tsv

hostname
export OMP_NUM_THREADS=$SLURM_NTASKS
module load benchmarks
stream
