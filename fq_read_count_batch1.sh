#!/bin/bash -l

#SBATCH -p high
#SBATCH -D /group/weimergrp/smh/MARS
#SBATCH -o /group/weimergrp/smh/MARS/slurm-log/fq_read_ct-stdout-%j.txt
#SBATCH -e /group/weimergrp/smh/MARS/slurm-log/fq_read_ct-stderr-%j.txt
#SBATCH -J fq_rd_ct
#SBATCH -N 1
#SBATCH -n 2 
#SBATCH -t 48:00:00
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=smhigdon@ucdavis.edu

# Name: fq_read_count.sh
# Created by: Shawn Higdon
# creation date: April 13, 2019
# A script to count number of fastq reads for MARS Microbiome RNAseq samples.

# Define Variable

DIR=Fecal_Data

echo -e "Sample\tReadcount" > ${DIR}/MARS_batch1_readcount.tsv

for i in ${DIR}/*_1.fq.gz
do
    echo $i
    bname=`basename $i`
    bname=`echo $bname | cut -d_ -f1`
    count=`echo $(zcat ${i}|wc -l)/4|bc`
    echo -e "${bname}\t${count}" >> ${DIR}/MARS_batch1_readcount.tsv
done

hostname
export OMP_NUM_THREADS=$SLURM_NTASKS
module load benchmarks
stream
