#!/bin/bash -l

THREADS
#$ -o log-BATCH_NAME
#$ -e err-BATCH_NAME
#$ -P PROJECT_NAME
#$ -N BATCH_NAME
#$ -l h_rt=24:00:00

module load matlab/2019b

matlab -nodisplay FLAGS -r "batchFunction(ARGUMENT); exit;"
