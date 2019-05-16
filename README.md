# RatCatcher
A general utility for parsing data and passing to analysis scripts.

In its simplest form, `RatCatcher` is an uncomplicated class that contains all the relevant information to find data on the cluster and produce batch files. You can use it to create a batch script that can be run on a high-performance computing cluster from your raw data and a custom analysis function, and then gather your data into a table afterwards.

It is agnostic to the format of the data, and to the type of analysis performed,
so that `RatCatcher` can be used to perform any number of analyses on any type of data.
`RatCatcher` scales well with increasing numbers of data files.

## How do I install it?
The best way is to clone the repository, or to download and unzip. Then, just add it to your MATLAB path. It is dependent on [`mtools`](https://github.com/sg-s/srinivas.gs_mtools).

## Usage example

In this example, we will load up MATLAB on our local computer,
and tell `RatCatcher` to collect from Caitlin's "A" and "B" data sets,
and perform the "Bandwidth Estimator" analysis.
On the cluster, we will run the auto-generated script, 
then back in MATLAB on our local computer, we will gather the data into a table.

Create the `RatCatcher` object.
At minimum, the following fields need to be filled out.

```matlab
r             = RatCatcher;
r.expID       = {'Caitlin', 'A'; 'Caitlin', 'B'};
r.remotepath  = '/projectnb/mypath2folder/cluster';
r.localpath   = '/mnt/mypath2folder/cluster';
r.protocol    = 'BandwidthEstimator';
```

Create the batch scripts.
This will generate files in `r.localpath`.

```matlab
r.batchify();
```

Go onto the cluster and submit the script.

```bash
ssh username@foo.bar
cd /projectnb/mypath2folder/cluster
qsub Caitlin-A-Caitlin-B-BandwidthEstimator.sh
```

Wait until the run has completed, then

```matlab
dataTable = r.gather;
dataTable = r.stitch(dataTable);
```

This will gather the data into a `table` in MATLAB on your local computer.
`stitch`ing appends the full path of the raw data.

## What does RatCatcher actually do?

Behind-the-scenes, this is how `RatCatcher` works:

1. It finds the data specified by the object's properties using the `parse` function.
2. Then, it stores the filenames to the data in `filenames.txt`, and the file codes in `filecodes.csv`. The actual names of the file is a bit longer, incorporating the experimental ID, and the protocol, but each file will begin with `filenames` or `filecodes` respectively.
3. In addition, a batch script is created.

The batch script is a shell script that specifies options to the job scheduler ([SGE](https://www.bu.edu/tech/support/research/system-usage/running-jobs/submitting-jobs/)) on the cluster.

The `batchify` function also fills out several details, such as the name of the job. The most important
job of the batch script is to tell the cluster to run MATLAB and a function called the batch function.
This is a MATLAB function with the following form:

```matlab
function batchFunction(index, location, batchname, outfile, test)
  ...
end
```

Then, you can run the script on the cluster by submitting it using `qsub`.

```bash
# on the cluster
qsub scriptname.sh
```

Once the script finishes running, output files are produced in the directory specified by `RatCatcher`'s `remotepath`.
You can gather the data into a `table` in MATLAB with

```matlab
dataTable = r.gather();
```

## Class properties

`filenames` will be set automatically when you run `batchify`, though you can also generate your own with the static `build` function.
If `expID` is a row vector cell array, then `filenames` is a column vector cell array of full file paths to the raw data.
If `expID` is a matrix cell array, then `filenames` is a column vector cell array of column vector cell arrays of full file paths to the raw data.
This allows for easier separation of data and processed results into chunks.
If there aren't a lot of special conditions or parameters in your data (i.e. you just have 100 experiments in the same condition),
then using a simple `expID` (and thus a single cell array of filenames) is perfectly fine.

`filecodes` is a field useful for storing numerical information that allows you to specify further within a data file. For example, if you had 100 recordings and kept track of cell and tetrode number, you might have a `100 x 2` matrix for your `filecodes`. These properties are intended to be available to the `batchify` function so that they can be written into the batch script that contains the function call to the batch function specified in `protocol` that performs the actual analysis.
If `expID` is a row vector cell array, then `filenames` is a column vector cell array of file codes.
If `expID` is a matrix cell array, then `filenames` is a column vector cell array of column vector cell arrays of file codes.

The `expID` field contains an character vector or cell array of character vectors that serves as an unambiguous identifier to the raw data to be analyzed.

> Say you have data saved in some filesystem, where each subfolder indicates different conditions of an experiment (dosage, animal, setup, etc.). Perhaps within each of those folders, you have yet more subfolders. That is, your experiment can be classified by two or more identifiers (e.g. animal and date of experiment).

The `expID` field reads rows as increasing specificity and columns as more data.
For example, if you were working with Caitlin's dataset from [this paper](http://www.jneurosci.org/content/early/2019/02/25/JNEUROSCI.1450-18.2019), your `expID` would look something like this:

```matlab
expID =

  3×2 cell array

    {'Caitlin'}    {'A'}
    {'Caitlin'}    {'B'}
    {'Caitlin'}    {'C'}
```

This would indicate that this is Caitlin's data from clusters `A`, `B`, and `C`. The power of the `expID` is that as long as it is specified in the `parse` function what to do with a certain `expID` pattern, it works. You can also bypass the `expID` process by delivering a list of filenames directly to the `RatCatcher` functions. You can get a list of filenames with the `RatCatcher.getFileNames()` function.

The `protocol` field determines which analysis should be performed. `RatCatcher` doesn't actually do any real calculations, but sets up the batch files needed to run the computations on a high-performance computing cluster. It looks for somewhere on your path where a function named `[protocol '.batchFunction']` is.

The `localpath` field contains the absolute path to where the batch files should be placed (when on your local computer) and the `remotepath` field contains the absolute path from the perspective of the high-performance computing cluster.

> For instance, if you mounted your cluster on your local machine at `/mnt/myproject/cluster/` then that is your `localpath`. If from the cluster's perspective (when accessing via `ssh`), your files are at `/projectnb/myproject/cluster` then that is your `remotepath`. If your local computer does not have the cluster mounted, `localpath` will be some path in your local file system and you will have to copy the files `RatCatcher` produces over to the `remotepath` before running the script on the cluster.

`project` is the name of the project on the cluster (who has to pay for the computer usage).

There are a host of other properties

* filenames
* filecodes
* batchname
* batchfuncpath
* batchscriptpath
* verbose

which allow you to override options automatically set during the batching process.
By manually setting any of these class properties to be non-empty, `RatCatcher` will use your preset instead.

The defaults are determined by running a series of functions

* `r.getFileNames()`
* `r.getBatchScriptName()`
* `r.getBatchScriptPath()`
* `r.getBatchFuncPath()`

which is performed inside the `r.validate()` function, and is automatically performed during `batchify`ing.

The `batchname` is the canonical kernel of text that appears in every file created by `RatCatcher`.
By default, it is a combination of all the parts of the `expID` and the `protocol`,
so it should be unique to each experimental dataset and analysis method.
Files created by `RatCatcher` have names like `filenames-batchname.txt`.

The batch function is a MATLAB (or function in another language) that performs the analysis protocol
on each file containing the raw or preprocessed data.
It is determined from the name of the `protocol`.
`RatCatcher` will try to find a MATLAB class on your computer with the same name as the specified `protocol`
and thence find a function named `batchFunction`.
You can also specify your own absolute path to any function on your MATLAB path to override this.

The batch script is the shell script that is run for each filename indicated.
It sets up the run-time environment on the cluster and then invokes the batch function
with the correct arguments.

The default script is `RatCatcher-generic-script.sh`, but this can be changed
by substituting any absolute path to a shell script on your MATLAB path.

## Pre-Processing

A general use of `RatCatcher` looks something like this:

Set up your `RatCatcher` object.

```matlab
r = RatCatcher;
r.expID         = {};
r.protocol      = 'BandwidthEstimator';
r.remotepath    = '/projectnb/mypath2folder/cluster';
r.localpath     = '/mnt/mypath2folder/cluster';
r.project       = 'hasselmogrp';
```

Then, batch your files. They will end up in `r.localpath`.

```matlab
r.batchify();
```

```matlab
filenames = RatCatcher.getFileNames(identifiers, filesig, masterpath);
```

The `identifiers` is very much like `expID` except that it contains only the discrete filenames.
The `filesig` is the pattern to search for within the files specified by `identifiers`.
Use `**` to indicate searching in all subfolders and `*` to indicate searching for anything that matches the pattern. For example,

```matlab
filesig = fullpath('**', '*.plx')
```

would find all files in the directory `identifiers` and subdirectories that are Plexon (`.plx`) files.

### Customizing parsing the raw data

The function `parse` performs a different operation based on who the experimenter (and alphanumeric code) is. If you are not built into the `RatCatcher` ecosystem yet, it is important to tell `parse` what to do with you. You can do this one of three ways:

1. If you are a part of the Hasselmo, Howard, or Eichenbaum labs, send me an email. You know who I am.
2. Generate a cell array of `filenames` and a list of `filecodes` by yourself and update the default (empty) properties in your `RatCatcher` object.
3. Add a new experimenter name to the `parse_core` function (inside `parse`) switch/case statement that expresses what to do to find the correct data, given an experimenter name.

### Customizing your batching

You can also force `batchify` to use custom data, locations, or scripts.

Under the basic usage, `batchify` uses the `parse` function to figure out
what `filenames` and `filecodes` you need based on the `expID` provided
(with instructions detailed in the `parse` function itself).

The function also uses
a default batch script, `RatCatcher-generic-script.sh`.
This script requests a 16-core node and outputs an error and log file.
It also limits the run to 24 hours before terminating.
Then, it loads MATLAB 2018a and runs the batch function from the command line.

`batchify` reads the properties from the `RatCatcher` object,
so to override the defaults, update the `RatCatcher` object's properties.

You can get extra feedback from the function by setting

```matlab
r.verbose = true;
```

```matlab
% r.batchify batches the files specified by the ratcatcher object
r.batchify();
```

### Customizing your batch script

Each protocol has to have a batch function as a static class method or package function.
When you specify the analysis method (in `r.protocol`), `RatCatcher` will find the right batch function.

The function has to:

1. Set up the MATLAB path on the cluster (if you are using MATLAB).
2. Acquire the filenames and file codes from the .txt and .csv file generated by `batchify`.
3. Read the data from a file using the filenames as a guide.
4. Perform the analysis.
5. Save the data.

The `index` is set by the job scheduler. If you have 10 jobs, it goes from 1-10, and is stored in the
environment variable `$SGE_TASK_ID`. The `batchify` function sets up the call to the MATLAB batch function from inside the batch script, and so sets the `index` argument to the task ID.

A good example of a batch function can be found [here](https://github.com/hasselmonians/BandwidthEstimator/blob/master/%40BandwidthEstimator/batchFunction.m).

Any custom batch script must be a `.sh` file on your `MATLAB` path.
The best way to check is with `which(r.batchscriptpath)` because that's how `batchify` actually does it.
`batchify` using string parsing to fill out the correct fields in the batch script.

* `PROJECT_NAME`: the name of the project on the cluster
* `BATCH_NAME`: the `batchname`
* `NUM_FILES`: the total number of datafiles upon which the protocol will be run
* `ARGUMENT`: the actual argument passed to the batch function

In order for `batchify` to work correctly, these tags should exist in the generic batch script.
They will be replaced with actual parameters during the batching process.

* `PROJECT_NAME` is set by the `RatCatcher` property
* `BATCH_NAME` is automatically generated or set by the user by an argument to `batchify`
* `NUM_FILES` is automatically determined
* `ARGUMENT` is more of a special case

### Customizing your batch function

The prototypical batch function has the following functional call:

```matlab
batchFunction(index, batchname, location, outfile, test)
```

* `index` is automatically set to correspond to the `SGE_TASK_ID` which iterates up to `NUM_FILES`
* `batchname` is, unsurprisingly, the `batchname` determined as above
* `location` is automatically set to the `remotepath` property of `RatCatcher`
* `outfile` is the name of the output file, also automatically determined
* `test` is a logical flag

The batch function can be _any_ function that has these arguments in this order.
It does not necessarily even have to be a MATLAB function either, if a custom batch script is used.

>> To see what a good batchfunction looks like, check [here](https://github.com/hasselmonians/BandwidthEstimator/blob/master/%40BandwidthEstimator/batchFunction.m).

### Customizing your protocol

A "protocol" is some process that operates on your data to get useful results. If this is computationally expensive and needs to happen on a lot of data, it's best to run it on a high-performance computing cluster. So far, the only complete `RatCatcher`-compatible analysis is called [BandwidthEstimator](https://github.com/hasselmonians/BandwidthEstimator).

The only requirement is that your analysis have a _batch function_ defined for it. It finds it by looking at:

```matlab
path2BatchFunction = which([r.protocol '.batchFunction']);
```
so it's best if the batch function is a static method of a class, or part of a package.
See below for more details.

You can also provide the path to a custom batch script by filling out the `batchfuncpath` property of the `RatCatcher` object.

## Running your scripts

`batchify` creates a batch script that will run (using `qsub`) all the jobs on the cluster,
and put the output files where the data should be stored.

```bash
# on the cluster
qsub scriptName.sh
```

### What is the generic batch script?

This script is a template that `batchify` fills in with the correct values.
It requires 16 cores on the cluster, creates a log file and error file,
sets the name of the project, limits to a 24-hour run,
and then runs MATLAB from the command line.

### Generating multiple scripts

A new script is generated for each different `expID`.
A single call to the `qsub` command on the cluster will run the script on each data file,
producing an output file or files for each (if directed in the batch function).

If you want to run multiple analyses, you will need multiple calls to `batchify`
with the correctly specified `RatCatcher` object.

## Post-Processing

Once the jobs have been run, the data can be gathered.

```matlab
dataTable = r.gather();
```

The paths to the raw data can be stitched onto the data table, for easy reference.

```matlab
dataTable = r.stitch(dataTable);
```

## Extra features

You can go from a saved `dataTable` to an analysis object and the `Session` object
(from [`CMBHOME`](https://github.com/hasselmonians/CMBHOME))
by using the `extract` function.

```matlab
[best, root] = RatCatcher.extract(dataTable, index, 'BandwidthEstimator');
```

Conversely, a `dataTable` can be indexed to find the indices which correspond to a given filename and cell number.
`parse` is called to determine the filenames and file codes.

```matlab
index = r.index(dataTable);
```

## Setting a preference file

You can create a function called `pref.m` inside of `../RatCatcher/@RatCatcher/` to automatically set up a custom `RatCatcher` object every time you instantiate one. This file is ignored by git. It should look something like this:

```matlab
function p = pref()
    p = struct;
    p.expID           = {'experimenter', 'id1'; 'experimenter', 'id2'};
    p.protocol        = 'BandwidthEstimator';
    p.localpath       = 'myPath2ClusterFromLocalComputer';
    p.remotepath      = 'myPath2ClusterFromRemoteComputer';
    p.project         = 'hasselmogrp';
end
```
If this function exists, all future instantiated `RatCatcher` objects will have these properties set. If you don't want to set a property, set it to `[]` instead.

## License Information

`RatCatcher` is written by Alec Hoyland and is released under the GNU General Public License 3.0. The `natsort` functions were written by Stephen Cobeldick (c) 2018. `mtools` were written and/or archived by [sg-s](https://github.com/sg-s).
