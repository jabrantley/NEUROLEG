#!/bin/bash
### Specify job parameters (use this for CPU heavy computations)
#SBATCH -J RidgeRegressionGridSearch_AllJoint_Gonio_CentralChans
#SBATCH -o clusterjobs/RidgeRegressionGridSearch_AllJoint_Gonio_CentralChans.o%j      # name of the job
#SBATCH -t 30:00:00         # time requested
#SBATCH -N 1 -n 11  -c 1
#SBATCH -p long
#SBATCH --mem=64GB
#SBATCH -A contreras-vidal
#SBATCH --mail-user=justin.a.brantley@gmail.com
#SBATCH --mail-type=END,FAIL

module load matlab/r2018b
matlab -nodisplay < AnalyzeEEGvsMOVE_RunRidgeRegression_GonioDataOnly_CentralChans.m
