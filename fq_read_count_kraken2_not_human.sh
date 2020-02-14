#!/bin/bash -l

#SBATCH -p high
#SBATCH -D /group/weimergrp/smh/MARS
#SBATCH -o /group/weimergrp/smh/MARS/slurm-log/fq_read_ct-stdout-%j.txt
#SBATCH -e /group/weimergrp/smh/MARS/slurm-log/fq_read_ct-stderr-%j.txt
#SBATCH -J fq_rd_ct
#SBATCH -N 1
#SBATCH -n 2
#SBATCH --array 1-151
#SBATCH -t 48:00:00
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=smhigdon@ucdavis.edu

# Name: fq_read_count_kraken_not_human.sh
# Created by: Shawn Higdon
# creation date: June 25, 2019
# A script to count number of fastq reads for MARS Microbiome RNAseq samples.

# Define Variable

OUTPUT_FOLDER=analysis/kraken_microbe_reads # folder for all output
mkdir -p $OUTPUT_FOLDER

SEEDFILE=input_files/fq_not_human_inputs.txt # the list of PE_1 files that will be processed (absolute path), 1 per line.

SEED=$(cat $SEEDFILE | head -n $SLURM_ARRAY_TASK_ID | tail -n 1)

bname=`basename $SEED`
bname=`echo $bname | cut -d. -f1`

count=`echo $(zcat ${SEED}|wc -l)/4|bc`
echo -e "${bname}\t${count}" >> ${OUTPUT_FOLDER}/${bname}_not_human_readcount.tsv

hostname
export OMP_NUM_THREADS=$SLURM_NTASKS
module load benchmarks
stream
