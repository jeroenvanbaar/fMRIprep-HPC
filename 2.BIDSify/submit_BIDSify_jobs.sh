#!/bin/bash

# Job Name
#SBATCH -J bidsify

# Core and memory
#SBATCH -c 2
#SBATCH --mem=8G
#SBATCH --account=YOUR_OSCAR_CONDO_HERE

# Walltime requested
#SBATCH -t 1:00:00

# Provide index values (TASK IDs)
#SBATCH --array=YOUR_SUBJECT_NUMBERS_HERE
# Use '%A' for array-job ID, '%J' for job ID and '%a' for task ID
#SBATCH -e bidsify_logs/bidsify_sub-%a.err
#SBATCH -o bidsify_logs/bidsify_sub-%a.out

# Messages to
#SBATCH --mail-type=ALL
#SBATCH --mail-user=YOUR_EMAIL@ADDRESS.HERE

# Use the $SLURM_ARRAY_TASK_ID variable to provide different inputs for each job
 
echo "Starting BIDSify for subject "$SLURM_ARRAY_TASK_ID

module load anaconda/3-5.2.0
source activate pp_fmri

python bidsify.py $SLURM_ARRAY_TASK_ID