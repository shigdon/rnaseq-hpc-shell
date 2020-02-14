#!/bin/bash -l

#SBATCH -p bmh
#SBATCH -A ctbrowngrp
#SBATCH -D /group/weimergrp/smh/MARS
#SBATCH -o /group/weimergrp/smh/MARS/slurm-log/MARS_humann2-stdout-%j.txt
#SBATCH -e /group/weimergrp/smh/MARS/slurm-log/MARS_humann2-stderr-%j.txt
#SBATCH -J MARS_hum2
#SBATCH -N 1
#SBATCH -c 24 
#SBATCH --mem 256000 
#SBATCH --array 3,6-8,10-11 
#SBATCH -t 96:00:00
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=smhigdon@ucdavis.edu

# Name: MARS_humann2_base.sh
# Created by: Shawn Higdon
# creation date: June 26, 2019
# An array script to run the humann2 pipeline on Microbial Reads from Human Meta-Transcriptomes.

# Load environment

source activate humann2

# Define Variable

OUTPUT_FOLDER=analysis # folder for all output
mkdir -p $OUTPUT_FOLDER

SEEDFILE=input_files/MARS_humann2_xlarge_inputs.txt # the list of fastq files that will be processed (absolute path), 1 per line.

SEED=$(cat $SEEDFILE | head -n $SLURM_ARRAY_TASK_ID | tail -n 1)

bname=`basename $SEED`
bname=`echo $bname | cut -d. -f1`

SAMPLE_FOLDER=$OUTPUT_FOLDER/${bname}
mkdir -p $SAMPLE_FOLDER

HUMANN2_FOLDER=$SAMPLE_FOLDER/humann2
mkdir -p $HUMANN2_FOLDER

# Run Humann2 Pipeline on Microbial Reads

srun humann2 \
	--input $SEED \
    --input-format fastq.gz \
	--output $HUMANN2_FOLDER \
    --output-basename ${bname} \
    --output-format tsv \
    --remove-temp-output \
    --resume \
    --threads $SLURM_JOB_CPUS_PER_NODE 

hostname
export OMP_NUM_THREADS=$SLURM_NTASKS
module load benchmarks
stream
