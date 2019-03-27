# RatCatcher
A general utility for parsing data and passing to analysis scripts.

In its simplest form, `RatCatcher` is an uncomplicated class that contains all the relevant information to find data on the cluster and produce batch files. You can use it to create a batch script that can be run on a high-performance computing cluster from your raw data and a custom analysis function, and then gather your data into a table afterwards.


## How do I install it?
The best way is to clone the repository, or to download and unzip. Then, just add it to your MATLAB path. It is dependent on [`mtools`](https://github.com/sg-s/srinivas.gs_mtools).

## How do I use it?

First, set up an empty `RatCatcher` object.

```matlab
r = RatCatcher
```

## Class properties

The `filenames` field is a cell array of character vectors that holds the filenames of the raw data to be processed. This variable does _not_ have to hold only filenames. They could specify folder names instead, since some experiments produce multiple data files (e.g. a video and a time series).

`filenames` will be set automatically when you run `batchify`, though you can also generate your own with the static `build` function.

`filecodes` is a field useful for storing numerical information that allows you to specify further within a data file. For example, if you had 100 recordings and kept track of cell and tetrode number, you might have a `100 x 2` matrix for your `filecodes`. These properties are intended to be available to the `batchify` function so that they can be written into the batch script that contains the function call to the batch function specified in `protocol` that performs the actual analysis.

The `expID` field contains an character vector or cell array of character vectors that serves as an unambiguous identifier to the raw data to be analyzed.

Say you have data saved in some filesystem, where each subfolder indicates different conditions of an experiment (dosage, animal, setup, etc.). Perhaps within each of those folders, you have yet more subfolders. That is, your experiment can be classified by two or more identifiers (e.g. animal and date of experiment).

The `expID` field reads rows as increasing specificity and columns as more data.
For example, if you were working with Caitlin's dataset from [this paper](http://www.jneurosci.org/content/early/2019/02/25/JNEUROSCI.1450-18.2019), your `expID` would look something like this:

```matlab
expID =

  3×2 cell array

    {'Caitlin'}    {'A'}
    {'Caitlin'}    {'B'}
    {'Caitlin'}    {'C'}
```

This would indicate that this is Caitlin's data from clusters `A`, `B`, and `C`. The power of the `expID` is that as long as it is specified in the `batchify` function what to do with a certain `expID` pattern, it works. You can also bypass the `expID` process by delivering a list of filenames directly to the `RatCatcher` functions. You can get a list of filenames with the `RatCatcher.listfiles()` function.

The `protocol` field determines which analysis should be performed. `RatCatcher` doesn't actually do any real calculations, but sets up the batch files needed to run the computations on a high-performance computing cluster. It looks for somewhere on your path where a function named `[protocol '.batchFunction']` is.

The `localPath` field contains the absolute path to where the batch files should be placed (when on your local computer) and the `remotePath` field contains the absolute path from the perspective of the high-performance computing cluster.

> For instance, if you mounted your cluster on your local machine at `/mnt/myproject/cluster/` then that is your `localPath`. If from the cluster's perspective (when accessing via `ssh`), your files are at `/projectnb/myproject/cluster` then that is your `remotePath`. If your local computer does not have the cluster mounted, `localPath` will be some path in your local file system and you will have to copy the files `RatCatcher` produces over to the `remotePath` before running the script on the cluster.

`project` is the name of the project on the cluster (who has to pay for the computer usage).

### Pre-Processing

A general use of `RatCatcher` looks something like this:

Set up your `RatCatcher` object.

```matlab
r = RatCatcher;
r.filenames     = [];
r.filecodes     = [];
r.expID         = {};
r.protocol      = 'BandwidthEstimator';
r.remotePath    = '/projectnb/hasselmogrp/hoyland/MLE-time-course/cluster';
r.localPath     = '/mnt/hasselmogrp/hoyland/MLE-time-course/cluster';
r.project       = 'hasselmogrp';
```

Then, batch your files. They will end up in `r.localPath`.

```matlab
r.batchify();
```

You can also specify lots of options:

```matlab
r.batchify(batchname, filenames, filecodes, path2BatchFunction)
```

such as a custom `batchname` rather than the very verbose (but unambiguous) one generated automatically. The `filenames` and `filecodes` fields are for if you want to ignore the properties set in your `RatCatcher` object and insert your own `filenames` and `filecodes` and path to a batch function.

This will automatically generate the batch files and put them in the directory specified in `localPath`. The `filenames` property is generated from the `expID` property, so as long as your file organization is accurately represented in `expID`, you are good to go.

You can build the `filenames` list by using the `listfiles` function. Though, in general, `batchify` will automatically `parse` for you.

```matlab
[filepaths] = RatCatcher.listfiles(identifiers, filesig, masterpath)
```

The `identifiers` is very much like `expID` except that it contains only the discrete filenames. The `filesig` is the pattern to search for within the files specified by `identifiers`. Use `**` to indicate searching in all subfolders and `*` to indicate searching for anything that matches the pattern. For example,

```matlab
filesig = fullpath('**', '*.plx')
```

would find all files in the directory `identifiers` and subdirectories that are Plexon (`.plx`) files.

#### Customizing parsing the raw data

The function `parse` performs a different operation based on who the experimenter (and alphanumeric code) is. If you are not built into the `RatCatcher` ecosystem yet, it is important to tell `parse` what to do with you. You can do this one of three ways:

1. If you are a part of the Hasselmo, Howard, or Eichenbaum labs, send me an email. You know who I am.
2. Generate a cell array of `filenames` and a list of `filecodes` by yourself and pass them to `batchify` as arguments.
3. Add a new experimenter name to the `parse_core` function (inside `parse`) switch/case statement that expresses what to do to find the correct data, given an experimenter name.

You can also force `batchify` to use custom data or locations.
`filenames` is a cell array of file names.
`filecodes` is an n x 2 matrix of cell numbers.

```matlab
% r.batchify batches the files specified by the ratcatcher object

% uses a custom batchname rather than one generated from RATCATCHER.GETBATCHNAME
r.batchify(batchname)

% overrides using RATCATCHER.PARSE to find the filenames and filecodes
% filenames should be a cell array, filecodes should be an n x 2 matrix
r.batchify(batchname, filenames, filecodes)

% overrides using RATCATCHER.PARSE and provides a custom batch function
% pathname should be a character vector (path to the function)
r.batchify(batchname, filenames, filecodes, pathname)

% does not display verbose display text
r.batchify(batchname, filenames, filecodes, pathname, false)
```

#### Customizing your analysis

An "analysis" is some process that operates on your data to get useful results. If this is computationally expensive and needs to happen on a lot of data, it's best to run it on a high-performance computing cluster. So far, the only complete `RatCatcher`-compatible analysis is called [BandwidthEstimator](https://github.com/hasselmonians/BandwidthEstimator).

The only requirement is that your analysis have a _batch function_ defined for it. It finds it by looking at:

```matlab
path2BatchFunction = which([r.analysis '.batchFunction']);
```
so it's best if the batch function is a static method of a class, or part of a package. See below for more details.

You can also provide the path to a custom batch script as the fourth argument to `batchify` (excluding the object).
`pathname` is the full path to your custom batch function.
You can replace any of them with `[]` to omit overriding that change.

```matlab
% optional uses
r.batchify(filename, cellnum, pathname);
r.batchify([], [], pathname);
```

#### Generating multiple scripts

A new script is generated for 

### Running your scripts

`batchify` creates a batch script that will run (using `qsub`) all the jobs on the cluster, and put the output files where the data should be stored.

```bash
# on the cluster
qsub scriptName.sh
```

#### What is the generic script?

This script is a template that `batchify` fills in with the correct values. It requires 16 cores on the cluster, creates a log file and error file, sets the name of the project, limits to a 24-hour run, and then runs MATLAB from the command line.

### Post-Processing

Once the jobs have been run, the data can be gathered.

```matlab
dataTable = r.gather();
```

The paths to the raw data can be stitched onto the data table, for easy reference.

```matlab
dataTable = r.stitch(dataTable);
```

You can go from a saved `dataTable` to an analysis object and the `Session` object (from [`CMBHOME`](https://github.com/hasselmonians/CMBHOME)) by using the `extract` function.

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
