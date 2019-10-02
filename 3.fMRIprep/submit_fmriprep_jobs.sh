#!/bin/bash

# Job Name
#SBATCH -J fMRIprep

# Core and memory
#SBATCH -c 8
#SBATCH --mem=32G
#SBATCH --account=YOUR_OSCAR_CONDO_HERE

# Walltime requested
#SBATCH -t 24:00:00

# Provide index values (TASK IDs)
#SBATCH --array=YOUR_SUBJECT_NUMBERS_HERE
# Use '%A' for array-job ID, '%J' for job ID and '%a' for task ID
#SBATCH -e fmriprep_logs/fmriprep_sub-%a.err
#SBATCH -o fmriprep_logs/fmriprep_sub-%a.out

# Messages to
#SBATCH --mail-type=ALL
#SBATCH --mail-user=YOUR_EMAIL@ADDRESS.HERE

# Use the $SLURM_ARRAY_TASK_ID variable to provide different inputs for each job
 
echo "Starting fMRIprep for subject "$SLURM_ARRAY_TASK_ID

subject_dir=$(printf "sub-%03d" $SLURM_ARRAY_TASK_ID)
scratch_dir=$(printf "/s1/sub-%03d" $SLURM_ARRAY_TASK_ID)

echo "Scratch directory: "$scratch_dir

singularity run --cleanenv -B /gpfs_home/jvanbaar/data/jvanbaar/polarization:/p1,/gpfs/scratch/jvanbaar:/s1 fmriprep-1.5.0rc2.simg /p1/sourcedata /p1/derivatives participant -w $scratch_dir --participant-label $subject_dir --fs-license-file /p1/freesurfer.txt --fs-no-reconall --output-spaces MNI152NLin2009cAsym --resource-monitor --write-graph --use-syn-sdc --ignore fieldmaps --n_cpus 8 --mem_mb 32000
