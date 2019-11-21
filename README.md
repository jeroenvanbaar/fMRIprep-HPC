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
cd YOUR_DIRECTORY_WITH_submit_DICOM_convert_jobs.sh
mkdir dicom_convert_logs
sbatch submit_DICOM_convert_jobs.sh
```
# 2. BIDSify
1. Enter dataset parameters - e.g. per subject, indicate which task was performed during each scanner run, which run was the anatomical scan, etc. Use notebook `2.BIDSify/Enter_dataset_parameters.ipynb` to do this & write to .json file per subject which is then read in step 3.
2. edit `2.BIDSify/bidsify.py` and `2.BIDSify/submit_BIDSify_jobs.sh` to fit your folder structure.
2. Use Oscar to run bidsify.py on your dataset:
```bash
ssh -X jvanbaar@ssh.ccv.brown.edu
cd YOUR_DIRECTORY_WITH_submit_BIDSify_jobs.sh
mkdir bidsify_logs
sbatch submit_BIDSify_jobs.sh
```

# 3. Preprocess using fMRIPrep
1. Download freesurfer license file from https://surfer.nmr.mgh.harvard.edu/registration.html and update its location in `3.fMRIprep/submit_fmriprep_jobs.sh`
2. Create fMRIprep Singularity container:
```bash
ssh -X jvanbaar@ssh.ccv.brown.edu
cd YOUR_PROJECT_DIRECTORY
singularity build /my_images/fmriprep-<version>.simg docker://poldracklab/fmriprep:<version>
# Replace <version> by your desired fMRIprep version, see https://fmriprep.readthedocs.io/en/stable/changes.html for stable versions or https://github.com/poldracklab/fmriprep/releases for all versions incl. release candidates (rc).
# NOTE: For me (jvanbaar), right now (2019/11/04), building the container works when on an Oscar login node, but NOT on compute nodes. No idea why.
```
3. Update the location of the fMRIprep container in `3.fMRIprep/submit_fmriprep_jobs.sh`
4. Update subject numbers in  `3.fMRIprep/submit_fmriprep_jobs.sh`
5. Send fMRIprep jobs to Oscar:
```bash
ssh -X jvanbaar@ssh.ccv.brown.edu
cd YOUR_DIRECTORY_WITH_submit_fmriprep_jobs.sh
mkdir fmriprep_logs
sbatch submit_fmriprep_jobs.sh
```
