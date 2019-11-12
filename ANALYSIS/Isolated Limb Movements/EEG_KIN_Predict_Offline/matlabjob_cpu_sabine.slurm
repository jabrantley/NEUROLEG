#!/bin/bash
### Specify job parameters (use this for CPU heavy computations)
#SBATCH -J KalmanGridSearch_RK_EachChanBSclean
#SBATCH -o clusterjobs/KalmanGridSearch_RK_EachChanBSclean.o%j      # name of the job
#SBATCH -t 24:00:00         # time requested
#SBATCH -N 2 -n 30  -c 1
#SBATCH -p long
#SBATCH --mem=64GB
#SBATCH -A contreras-vidal
#SBATCH --mail-user=justin.a.brantley@gmail.com
#SBATCH --mail-type=END,FAIL

module load matlab/r2018b
matlab -nodisplay < AnalyzeEEGvsMOVE_RunKalmanFilter_GonioDataOnly_UseEachChan.m