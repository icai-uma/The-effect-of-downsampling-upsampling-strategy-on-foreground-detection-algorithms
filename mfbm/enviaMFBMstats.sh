#!/usr/bin/env bash
# The name to show in queue lists for this job:
#SBATCH -J enviaMFBMstats.sh

# Number of desired cpus:
#SBATCH --cpus=1

# Amount of RAM needed for this job:
#SBATCH --mem=3gb

# The time the job will be running:
#SBATCH --time=150:00:00

# Remove only one comment symbol from one of the partition lines to send it to the short or medium queues:
##SBATCH --partition=shortq
##SBATCH --partition=mediumq
##SBATCH --partition=longq
#SBATCH --partition=all_nodes

# To use GPUs you have to request them:
##SBATCH --gres=gpu:1

# If you need nodes with special features uncomment the desired constraint line:
#SBATCH --constraint=bigmem
##SBATCH --constraint=cal

# Set output and error files
#SBATCH --error=jobMFBM.%J.err
#SBATCH --output=jobMFBM.%J.out

export LD_LIBRARY_PATH="/mnt/home/users/tic_163_uma/miguelangel/unidad_z/bgs/opencv-2.4.11/build/lib:/usr/local/cuda-4.2/lib64:/mnt/home/users/tic_163_uma/miguelangel/unidad_z/bgs/tbb/lib/ia32/gcc4.1:/mnt/home/users/tic_163_uma/miguelangel/unidad_z/metodosBGS/codigos/MetodosBGS"


# MAKE AN ARRAY JOB, SLURM_ARRAYID will take values from 1 to 1
#SARRAY --range=1-1

# To load some software (you can show the list with 'module avail'):
module load cuda/4
module load matlab

# the program to execute with its parameters:
perf stat -d time matlab -singleCompThread -r "try;run('./MFBMpicasso.m');end;"
