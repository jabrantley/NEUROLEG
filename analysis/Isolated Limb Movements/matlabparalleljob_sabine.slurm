#!/bin/bash
### Specify job parameters (use this for CPU heavy computations)
#SBATCH -J KalmanGridSearch
#SBATCH -o clusterjobs/KalmanGridSearch.o%j      # name of the job
#SBATCH -t 16:00:00         # time requested
#SBATCH -N 1 -n 17 -c 1
#SBATCH -p batch --constraint="gen10"
#SBATCH --mem=32GB
#SBATCH -A contreras-vidal
#SBATCH --mail-user=justin.a.brantley@gmail.com
#SBATCH --mail-type=END,FAIL

module load matlab/r2018b
matlab -nodisplay < AnalyzeEEGvsMOVE_RunKalmanFilter_PARALLEL.m