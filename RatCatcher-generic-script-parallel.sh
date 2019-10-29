#!/bin/bash -l

#$ -pe omp 16
#$ -o log
#$ -e err
#$ -P PROJECT_NAME
#$ -N BATCH_NAME
#$ -l h_rt=24:00:00
#$ -t 1-NUM_BINS

module load matlab/2018a

export SGE_TOTAL_BINS=NUM_BINS

matlab -nodisplay -singleCompThread -r "batchFunction_parallel(ARGUMENT); exit;"
