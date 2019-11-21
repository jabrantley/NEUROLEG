#!/bin/bash
### Specify job parameters (use this for CPU heavy computations)
#SBATCH -J KalmanGridSearch_AllJoint_Target_CentralChans
#SBATCH -o clusterjobs/KalmanGridSearch_AllJoint_Target_CentralChans.o%j      # name of the job
#SBATCH -t 30:00:00         # time requested
#SBATCH -N 1 -n 11  -c 1
#SBATCH -p long
#SBATCH --mem=64GB
#SBATCH -A contreras-vidal
#SBATCH --mail-user=justin.a.brantley@gmail.com
#SBATCH --mail-type=END,FAIL

module load matlab/r2018b
matlab -nodisplay < AnalyzeEEGvsMOVE_RunKalmanFilter_AdjustedKin_CentralChans.m
