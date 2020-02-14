#!/bin/bash -l

#SBATCH -p high
#SBATCH -D /group/weimergrp/smh/MARS
#SBATCH -o /group/weimergrp/smh/MARS/slurm-log/MARS_cat-stdout-%j.txt
#SBATCH -e /group/weimergrp/smh/MARS/slurm-log/MARS_cat-stderr-%j.txt
#SBATCH -J MARS_cat
#SBATCH -N 1
#SBATCH -n 4
#SBATCH --array 1-67
#SBATCH -t 72:00:00
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=smhigdon@ucdavis.edu

# Name: MARS_cat_reads.sh
# Created by: Shawn Higdon
# creation date: June 15, 2019
# A script to concatenate paired end read files of the same sample in the same direction from different sequencing runs.

# Define Variable

OUTPUT_FOLDER=concatenated_reads # folder for all output
mkdir -p $OUTPUT_FOLDER

SEEDFILE=input_files/MARS_cat1_inputs.txt # the list of PE read files that will be processed (absolute path), 1 per line.

SEED=$(cat $SEEDFILE | head -n $SLURM_ARRAY_TASK_ID | tail -n 1)

SEEDFILE2=input_files/MARS_cat2_inputs.txt # the list of PE read files that will be processed (absolute path), 1 per line.

SEED2=$(cat $SEEDFILE2 | head -n $SLURM_ARRAY_TASK_ID | tail -n 1)

bname=`basename $SEED`
bname=`echo $bname | cut -d. -f1`

# concatenate fq.gz files of same sample and read direction, pulling from seedfile1 and seedfile2

cat $SEED $SEED2 > $OUTPUT_FOLDER/${bname}.fq.gz 

hostname
export OMP_NUM_THREADS=$SLURM_NTASKS
module load benchmarks
stream
