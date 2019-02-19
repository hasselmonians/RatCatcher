# RatCatcher
A general utility for parsing data and passing to analysis scripts.

## How do I install it?
The best way is to clone the repository, or to download and unzip. Then, just add it to your MATLAB path. It is dependent on [`mtools`](https://github.com/sg-s/srinivas.gs_mtools).

## How do I use it?
In its simplest form, `RatCatcher` is a simple class that contains all the relevant information to find data on the cluster and produce batch files.

The `experimenter` field identifies where the data is stored. It is accessed when the `parse` function is called, which implements a different procedure based on how the experimenter saved their data.

The `alphanumeric` field provides further description. For example, if Caitlin stored her data in files named `Cluster_A`, `Cluster_B`, etc., then `experimenter` would be `'Caitlin'` and `alphanumeric` would be `'A'`.

The `analysis` field determines which analysis should be performed. `RatCatcher` doesn't actually do any real calculations, but sets up the batch files needed to run the computations on a high-performance computing cluster. It looks for somewhere on your path where a function named `[analysis '.batchFunction']` is.

The `localPath` field contains the absolute path to where the batch files should be placed (when on your local computer) and the `remotePath` field contains the absolute path from the perspective of the high-performance computing cluster. For instance

`namespec` determines what the output files should be named.

### Pre-Processing

A general use of `RatCatcher` looks something like this:

Set up your `RatCatcher` object.

```matlab
r = RatCatcher;
r.experimenter  = 'Caitlin';
r.alphanumeric  = 'A';
r.analysis      = 'BandwidthEstimator';
r.location      = '/home/ahoyland/code/MLE-time-course/cluster';
r.namespec      = 'output-Caitlin-A';
```

Then, batch your files. They will end up in `r.location`.

```matlab
r.batchify();
```

This creates a batch script that will run (using `qsub`) all the jobs on the cluster, and put the output files where the data should be stored.

```bash
# on the cluster
qsub scriptName.sh
```

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

Each analysis method has to have a batch function as a class method. When you specify the analysis method
(in `r.analysis`), `RatCatcher` will find the right batch function. The function has to:

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

## License Information
`RatCatcher` is written by Alec Hoyland and is released under the GNU General Public License 3.0. The `natsort` functions were written by Stephen Cobeldick (c) 2018. `mtools` are written and/or archived by [sg-s](https://github.com/sg-s).
