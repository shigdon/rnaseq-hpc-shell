#!/bin/bash -l

#SBATCH -p high
#SBATCH -D /group/weimergrp/smh/MARS
#SBATCH -o /group/weimergrp/smh/MARS/slurm-log/MARS_cat-stdout-%j.txt
#SBATCH -e /group/weimergrp/smh/MARS/slurm-log/MARS_cat-stderr-%j.txt
#SBATCH -J MARS_cat
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --array 1-152 
#SBATCH -t 72:00:00
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=smhigdon@ucdavis.edu

# Name: MARS_humann2_combine_pe_reads.sh
# Created by: Shawn Higdon
# creation date: June 28, 2019
# A script to concatenate paired end reads classified as non-human with kraken2 for input to humann2.

# Define Variable

OUTPUT_FOLDER=analysis/humann2_reads # folder for all output
mkdir -p $OUTPUT_FOLDER

SEEDFILE=input_files/kraken2_not_human_R1_inputs.txt # the list of PE_1 files that will be processed (absolute path), 1 per line.

SEED=$(cat $SEEDFILE | head -n $SLURM_ARRAY_TASK_ID | tail -n 1)

SEEDFILE2=input_files/kraken2_not_human_R2_inputs.txt # the list of PE_2 files that will be processed (absolute path), 1 per line.

SEED2=$(cat $SEEDFILE2 | head -n $SLURM_ARRAY_TASK_ID | tail -n 1)

bname=`basename $SEED`
bname=`echo $bname | cut -d. -f1`

cat $SEED $SEED2 > $OUTPUT_FOLDER/${bname}.not_human-pe.fq.gz


export OMP_NUM_THREADS=$SLURM_NTASKS
module load benchmarks
stream
