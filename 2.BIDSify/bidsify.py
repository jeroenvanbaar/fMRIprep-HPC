import numpy as np
import pandas as pd
import sys, glob, os, json, gzip, shutil
from shutil import copyfile

# Subject
if len(sys.argv) < 2:
    exit("Needs subject number as input argument")
else:
    sub = int(sys.argv[1])

# Directories
baseDir = '/gpfs_home/jvanbaar/data/jvanbaar/polarization/' # CHANGE THIS
print('Base dir: %s'%baseDir)
datasetDir = baseDir + 'sourcedata'
niftiDir = baseDir + 'dicomconvert'
derivativesDir = baseDir + 'derivatives'

# Default sequence info
func_json_template = {'RepetitionTime': 1.5,
  'EchoTime': 0.03,
  'FlipAngle': 72,
  'MultibandAccelerationFactor': 3}
# HERE I AM TAKING SLICE TIMES FROM A FILE I CREATED ONCE FOR THE ENTIRE DATASET
#  - BUT BETTER TO READ FROM DICOM HEADER PER SUBJECT OR EVEN PER RUN.
#    See Slice_time_extraction_from_DICOM_header.ipynb
sliceTimes = list(np.array([round(float(pd.read_csv('%s/dicomconvert/slicetimes.txt'%baseDir,
           header=None).values[i][0]))/1000 for i in np.arange(60)]))
print('Slice times loaded: %s etc...'%sliceTimes[:5])

# Run
print('\\\\\\\\\ SUBJECT %i /////\n'%sub)
with open('%s/%03d/dataset_params.json'%(niftiDir,sub), 'r') as fp:
    sub_params = json.load(fp)

print('Functional runs: %s'%sub_params['func_run'])

## Create directories
subDir = datasetDir + '/sub-%03d'%(sub)
sesDir = datasetDir + '/sub-%03d/ses-%d'%(sub,sub_params['ses'])
anatDir = datasetDir + '/sub-%03d/ses-%d/anat'%(sub,sub_params['ses'])
funcDir = datasetDir + '/sub-%03d/ses-%d/func'%(sub,sub_params['ses'])
dirList = [subDir, sesDir, anatDir, funcDir]
dirType = ['Subject directory', 'Session directory', 'Anat directory', 'Func directory']
for di, curDir in enumerate(dirList):
    print('%s'%dirType[di])
    if not os.path.exists(curDir):
        print('...creating at %s'%curDir)
        os.mkdir(curDir)
    else:
        print('...already exists at:\n%s'%(curDir))

## Anatomical scans - rename and gzip:
run = sub_params['anat_run']
source = niftiDir + '/%03d/1_%03d_%s_%s/%03d_%s.nii'%(
    sub,sub_params['anat_run'],sub_params['anat_sequence'],
    sub_params['date'],sub,sub_params['anat_sequence'])
destination = anatDir + '/sub-%03d_ses-%d_T1w.nii.gz'%(sub,sub_params['ses'])
if os.path.isfile(source):
#     copyfile(source,destination)
    with open(source, 'rb') as f_in, gzip.open(destination, 'wb') as f_out:
        shutil.copyfileobj(f_in, f_out)
    print('Copied T1 to %s'%destination)

## Functional scans - rename, gzip, add json:
for func_task in sub_params['func_run'].keys():
    print(func_task)
    for ri,run in enumerate(sub_params['func_run'][func_task]):
        print(run)
        dateUse = sub_params['date']
        source = niftiDir + '/%03d/1_%03d_%s_%s/%03d_%s.nii'%(
            sub,run,sub_params['func_sequence'],
            dateUse,sub,sub_params['func_sequence'])
        destination = funcDir + '/sub-%03d_ses-%d_task-%s_run-%i_bold.nii.gz'%(
            sub,sub_params['ses'],func_task,ri+1)
        json_destination = destination[:-6] + 'json'
        func_json = func_json_template.copy()
        func_json['SliceTiming'] = sliceTimes
        func_json['TaskName'] = func_task
        with open(source, 'rb') as f_in, gzip.open(destination, 'wb') as f_out:
            shutil.copyfileobj(f_in, f_out)
        with open(json_destination, 'w') as outfile:
            outfile.seek(0)
            json.dump(func_json, outfile)