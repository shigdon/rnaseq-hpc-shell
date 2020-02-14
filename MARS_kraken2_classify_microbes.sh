#!/bin/bash -l

#SBATCH -p high
#SBATCH -D /group/weimergrp/smh/MARS
#SBATCH -o /group/weimergrp/smh/MARS/slurm-log/MARS_krak2_class-stdout-%j.txt
#SBATCH -e /group/weimergrp/smh/MARS/slurm-log/MARS_krak2_class-stderr-%j.txt
#SBATCH -J OVF_krak2_class
#SBATCH -N 1
#SBATCH -n 24 
#SBATCH --array 54
#SBATCH -t 48:00:00
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=smhigdon@ucdavis.edu

# Name: MARS_kraken2_classify_microbes.sh
# Created by: Shawn Higdon
# creation date: June 17, 2019
# An array script to classify fastq reads from that survived after using kraken2 to filter out reads classified as human.

# Load environment

source activate kraken2

# Define Variable

OUTPUT_FOLDER=analysis # folder for all output
mkdir -p $OUTPUT_FOLDER

SEEDFILE=input_files/MARS_kraken2_microbial_R1_inputs.txt # the list of microbial PE_1 files that will be processed (absolute path), 1 per line.

SEED=$(cat $SEEDFILE | head -n $SLURM_ARRAY_TASK_ID | tail -n 1)

SEEDFILE2=input_files/MARS_kraken2_microbial_R2_inputs.txt # the list of microbial PE_2 files that will be processed (absolute path), 1 per line.

SEED2=$(cat $SEEDFILE2 | head -n $SLURM_ARRAY_TASK_ID | tail -n 1)

bname=`basename $SEED`
bname=`echo $bname | cut -d. -f1`

SAMPLE_FOLDER=$OUTPUT_FOLDER/${bname}
mkdir -p $SAMPLE_FOLDER

DB=/home/smhigdon/mnt/krakenDB/kraken2_microbes

KRAKEN2_FOLDER=$SAMPLE_FOLDER/kraken2
mkdir -p $KRAKEN2_FOLDER

MICROBE_FOLDER=$KRAKEN2_FOLDER/microbes
mkdir -p $MICROBE_FOLDER

# Classify microbial reads using Kraken2 

kraken2 \
	--threads 24 \
	--gzip-compressed \
	--paired \
	--db $DB \
	--output $MICROBE_FOLDER/${bname}.output.tsv \
	--report $MICROBE_FOLDER/${bname}.report.tsv \
	--use-names \
	--report-zero-counts \
	$SEED \
	$SEED2

hostname
export OMP_NUM_THREADS=$SLURM_NTASKS
module load benchmarks
stream
