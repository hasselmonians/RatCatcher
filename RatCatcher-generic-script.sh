#!/bin/bash -l

#$ -pe omp 8
#$ -o log
#$ -e err
#$ -P hasselmogrp
#$ -N BATCH_NAME
#$ -l h_rt=24:00:00
#$ -t 1-NUM_FILES

module load matlab/2018a

matlab -nodisplay -singleCompThread -r "batchFunction(ARGUMENT); exit;"
