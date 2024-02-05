#!/usr/bin/env bash
# The name to show in queue lists for this job:
#SBATCH -J batch_bgsOrigCAMOUOW.sh

# Number of desired cpus:
# Para pedir todos los cores de una maquina hacer igual a 16
#SBATCH --cpus=1

# Amount of RAM needed for this job:
#SBATCH --mem=4gb

# The time the job will be running:
##SBATCH --time=23:00:00
#SBATCH --time=15:00:00

# Remove only one comment symbol from one of the partition lines to send it to the short or medium queues:
##SBATCH --partition=shortq
##SBATCH --partition=mediumq
##SBATCH --partition=longq
##SBATCH --partition=all_nodes

# To use GPUs you have to request them:
##SBATCH --gres=gpu:1

# If you need nodes with special features uncomment the desired constraint line:
# cal: esto es para utilizar siempre el mismo tipo de maquina
##SBATCH --constraint=bigmem
##SBATCH --constraint=cal
#SBATCH --constraint=cal

# Set output and error files
#SBATCH --error=jobBMFT.%J.err
#SBATCH --output=jobBMFT.%J.out



# MAKE AN ARRAY JOB, SLURM_ARRAYID will take values from 1 to 6240 (NUMBER OF TUNED CONFIGURATIONS)
##SBATCH --array=1-6240
## NumVideos * NumResizeFactors * NumTypeDownsamplings = 10*7*4 = 280
#SBATCH --array=1-10

# To load some software (you can show the list with 'module avail'):
module load matlab


# the program to execute with its parameters:
##perf stat -d time matlab -singleCompThread -r "try;run('./BatchBackgroundMFT.m');end;"
matlab -nodisplay -nodesktop -nojvm -singleCompThread -r "try;run('./bgsOrigCAMOUOW.m');end;"
