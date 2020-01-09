#!/bin/bash -l

#$ -pe omp 16
#$ -o log
#$ -e err
#$ -P PROJECT_NAME
#$ -N BATCH_NAME
#$ -l h_rt=24:00:00
#$ -t 1-NUM_FILES

module load matlab/2019b

matlab -nodisplay -singleCompThread -r "batchFunction(ARGUMENT); exit;"
