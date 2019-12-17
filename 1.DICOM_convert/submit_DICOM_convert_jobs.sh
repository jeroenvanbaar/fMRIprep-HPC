#!/bin/bash

# Job Name
#SBATCH -J dicom_convert

# Core and memory
#SBATCH -c 1
#SBATCH --mem=2G
#SBATCH --account=YOUR_OSCAR_CONDO_HERE

# Walltime requested
#SBATCH -t 1:00:00

# Provide index values (TASK IDs)
#SBATCH --array=YOUR_SUBJECT_NUMBERS_HERE
# Use '%A' for array-job ID, '%J' for job ID and '%a' for task ID
#SBATCH -e dicom_convert_logs/dicom_convert_sub-%a_err.txt
#SBATCH -o dicom_convert_logs/dicom_convert_sub-%a_out.txt

# Messages to
#SBATCH --mail-type=ALL
#SBATCH --mail-user=YOUR_EMAIL@ADDRESS.HERE

# Use the $SLURM_ARRAY_TASK_ID variable to provide different inputs for each job
 
echo "Starting dicom convert for subject "$SLURM_ARRAY_TASK_ID

module load mriconvert/2.1.0 libpng12/1.2.57

folder_name=$(printf "MRI_scanner/%03d_%03d" $SLURM_ARRAY_TASK_ID $SLURM_ARRAY_TASK_ID)

echo "Grabbing data from "$folder_name

mcverter -o dicomconvert -f nifti -n -v -j -x -d -F %PN_%PR $folder_name
