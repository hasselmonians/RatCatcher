# RatCatcher
A general utility for parsing data and passing to analysis scripts.

In its simplest form, `RatCatcher` is an uncomplicated class that contains all the relevant information to find data on the cluster and produce batch files. You can use it to create a batch script that can be run on a high-performance computing cluster from your raw data and a custom analysis function, and then gather your data into a table afterwards.


## How do I install it?
The best way is to clone the repository, or to download and unzip. Then, just add it to your MATLAB path. It is dependent on [`mtools`](https://github.com/sg-s/srinivas.gs_mtools).

## How do I use it?

In order for `RatCatcher` to work, the following fields must be set. They are all character vectors.

First, set up an empty `RatCatcher` object.

```matlab
r = RatCatcher
```

The `experimenter` field identifies where the data is stored. It is accessed when the `parse` function is called, which implements a different procedure based on how the experimenter saved their data.

The `alphanumeric` field provides further description.

> For example, if Caitlin stored her data in files named `Cluster_A`, `Cluster_B`, etc., then `experimenter` would be `'Caitlin'` and `alphanumeric` would be `'A'`.

The `analysis` field determines which analysis should be performed. `RatCatcher` doesn't actually do any real calculations, but sets up the batch files needed to run the computations on a high-performance computing cluster. It looks for somewhere on your path where a function named `[analysis '.batchFunction']` is.

The `localPath` field contains the absolute path to where the batch files should be placed (when on your local computer) and the `remotePath` field contains the absolute path from the perspective of the high-performance computing cluster.

> For instance, if you mounted your cluster on your local machine at `/mnt/myproject/cluster/` then that is your `localPath`. If from the cluster's perspective (when accessing via `ssh`), your files are at `/projectnb/myproject/cluster` then that is your `remotePath`. If your local computer does not have the cluster mounted, `localPath` will be some path in your local file system and you will have to copy the files `RatCatcher` produces over to the `remotePath` before running the script on the cluster.

`namespec` determines what the output files should be named. Files will be named starting with `namespec-experimenter-alphanumeric-analysis-`. It's best to set it to something like `'output'` if you're feeling uncreative.

`project` is the name of the project on the cluster (who has to pay for the computer usage).

### Pre-Processing

A general use of `RatCatcher` looks something like this:

Set up your `RatCatcher` object.

```matlab
r = RatCatcher;
r.experimenter  = 'Caitlin';
r.alphanumeric  = 'A';
r.analysis      = 'BandwidthEstimator';
r.location      = '/home/ahoyland/code/MLE-time-course/cluster';
r.namespec      = 'output';
r.project       = 'hasselmogrp';
```

Then, batch your files. They will end up in `r.localPath`.

```matlab
r.batchify();
```

#### Customizing parsing the raw data

The function `parse` performs a different operation based on who the experimenter (and alphanumeric code) is. If you are not built into the `RatCatcher` ecosystem yet, it is important to tell `parse` what to do with you. You can do this one of three ways:

1. If you are a part of the Hasselmo, Howard, or Eichenbaum labs, send me an email. You know who I am.
2. Generate a cell array of filenames and a list of cell numbers/indices by yourself and pass them to `batchify` as second and third arguments.
3. Add a new experimenter name to the `parse_core` function (inside `parse`) switch/case statement that expresses what to do to find the correct data, given an experimenter name.

#### Generating multiple scripts

If `alphanumeric` is a cell array of character vectors, multiple scripts will be generated, with their accompanying filename and cellnums files. They will all be created in `r.localPath`. This is useful when you want to run the same analysis on multiple subsets of data and keep track of them separately.

### Running your scripts

`batchify` creates a batch script that will run (using `qsub`) all the jobs on the cluster, and put the output files where the data should be stored.

```bash
# on the cluster
qsub scriptName.sh
```

#### What is the generic script?

This script is a template that `batchify` fills in with the correct values. It requires 16 cores on the cluster, creates a log file and error file, sets the name of the project, limits to a 24-hour run, and then runs MATLAB from the command line.

### Customizing your analysis

An "analysis" is some process that operates on your data to get useful results. If this is computationally expensive and needs to happen on a lot of data, it's best to run it on a high-performance computing cluster. So far, the only complete `RatCatcher`-compatible analysis is called [BandwidthEstimator](https://github.com/hasselmonians/BandwidthEstimator).

The only requirement is that your analysis have a _batch function_ defined for it. It finds it by looking at:

```matlab
path2BatchFunction = which([r.analysis '.batchFunction']);
```
so it's best if the batch function is a static method of a class, or part of a package. See below for more details.

### Post-Processing

Once the jobs have been run, the data can be gathered.

```matlab
dataTable = r.gather();
```

The paths to the raw data can be stitched onto the data table, for easy reference.

```matlab
dataTable = r.stitch(dataTable);
```

You can go from a saved `dataTable` to an analysis object and the `Session` object (from `CMBHOME`) by using the `extract` function.

```matlab
[best, root] = RatCatcher.extract(dataTable, index, 'BandwidthEstimator');
```

Conversely, a `dataTable` can be indexed to find the indices which correspond to a given filename and cell number.
`parse` is called to determine the filenames and cell numbers.

```matlab
index = r.index(dataTable);
```

## What is a batch script?

Behind-the-scenes, this is how `RatCatcher` works:

1. It finds the data specified by the object's properties using the `parse` function.
2. Then, it stores the filenames to the data in `filenames.txt`, and the cell numbers in `cellnums.csv`. The actual names of the file is a bit longer, incorporating the experimenter, alphanumeric code, and the analysis method, but each file will begin with `filenames` or `cellnums` respectively.
3. In addition, a batch script is created.

The batch script is a shell script that specifies options to the job scheduler ([SGE](https://www.bu.edu/tech/support/research/system-usage/running-jobs/submitting-jobs/)) on the cluster.
The `batchify` function also fills out several details, such as the name of the job. The most important
job of the batch script is to tell the cluster to run MATLAB and a function called the batch function.
This is a MATLAB function with the following form:

```matlab
function batchFunction(index, batchname, location, outfile, test)
  ...
end
```

## What is a batch function?

Each analysis method has to have a batch function as a static class method or package function. When you specify the analysis method (in `r.analysis`), `RatCatcher` will find the right batch function. The function has to:

1. Set up the MATLAB path on the cluster.
2. Acquire the filenames and cell numbers from the .txt and .csv file generated by `batchify`.
3. Read the data from a file using the filenames as a guide.
4. Perform the analysis.
5. Save the data.

The `index` is set by the job scheduler. If you have 10 jobs, it goes from 1-10, and is stored in the
environment variable `$SGE_TASK_ID`. The `batchify` function sets up the call to the MATLAB batch function from inside the batch script, and so sets the `index` argument to the task ID.

The `batchname` is the `experimenter-alphanumeric-analysis` character vector that specifies which `filenames.txt` and `cellnums.csv` files to read.

The `location` is the full path to where on the cluster the batch function needs to look to find the `filenames.txt` and `cellnums.csv` that tell it how to access the data.

The `outfile` is the full path to where the data should be stored. Usually, this is the same as the location plus something extra, like `..output-1.csv` etc. Files are automatically named by `batchify` to correspond to the identity in the `filename.txt`
file _and_ the `$SGE_TASK_ID` variable.

`test` is a flag. It should be `true` when running on a local machine and `false` when running on the cluster. The reason is because it tells the cluster to set up a new full path. Running the batch function with `test=false` will mess up your MATLAB path, which gets tedious to fix each time.

A good example of a batch function can be found [here](https://github.com/hasselmonians/BandwidthEstimator/blob/master/%40BandwidthEstimator/batchFunction.m).

## Setting a preference file

You can create a function called `pref.m` inside of `../RatCatcher/@RatCatcher/` to automatically set up a custom `RatCatcher` object every time you instantiate one. This file is ignored by git. It should look something like this:

```matlab
function p = pref()
    p = struct;
    p.experimenter    = 'ExperimenterName';
    p.alphanumeric    = 'A'
    p.analysis        = 'BandwidthEstimator';
    p.localPath       = 'myPath2ClusterFromLocalComputer';
    p.remotePath      = 'myPath2ClusterFromRemoteComputer';
    p.namespec        = 'output';
    p.project         = 'hasselmogrp';
end
```
If this function exists, all future instantiated `RatCatcher` objects will have these properties set. If you don't want to set a property, set it to `[]` instead.

## License Information
`RatCatcher` is written by Alec Hoyland and is released under the GNU General Public License 3.0. The `natsort` functions were written by Stephen Cobeldick (c) 2018. `mtools` were written and/or archived by [sg-s](https://github.com/sg-s).
