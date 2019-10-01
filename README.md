# fMRIprep-HPC
Guide to preprocessing fMRI data using fMRIprep on a high-performance computing cluster using SLURM job manager. Specifically written for use with the CCV "Oscar" cluster at Brown University.

# 1. DICOM convert
1. Edit the bash script `1.DICOM_convert/submit_DICOM_convert_jobs.sh` to fit your folder structure and subject numbers.
   * `SBATCH --array=8,10-12`
      * This line contains subject numbers (in this case 8, 10, 11, and 12)
   * `folder_name=$(printf "MRI_scanner/%03d_%03d" $SLURM_ARRAY_TASK_ID $SLURM_ARRAY_TASK_ID)`
      * This line contains the path where my DICOMs are stored: `"MRI_scanner/%03d_%03d"`. Using the variable `$SLURM_ARRAY_TASK_ID` this will become, e.g. for subject 8, `MRI_scanner/008_008`. This is a relative path, meaning that the .sh script lives in the same directory where the folder 'MRI_scanner' also exists, but you should be able to replace it with an absolute path – should look something like `/gpfs/data/ofeldman/jvanbaar/polarization/MRI_scanner/%03d_%03d`
2. Store the script in a directory accessible to Oscar.
3. SSH into Oscar using the command line.
```bash
ssh -X jvanbaar@ssh.ccv.brown.edu
```
4. Send DICOM convert jobs to Oscar from command line (where you have SSH'ed into Oscar).
```bash
cd DIR_TO_SCRIPT
mkdir dicom_convert_logs
sbatch submit_DICOM_convert_jobs.sh
```
