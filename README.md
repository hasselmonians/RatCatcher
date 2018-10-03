# RatCatcher
A general utility for parsing data and passing to analysis scripts.

## How do I install it?
The best way is to clone the repository, or to download and unzip.

## How do I use it?
In its simplest form, `RatCatcher` is a simple class that contains all the relevant information to find data on the cluster and produce batch files.

* The `experimenter` field identifies where the data is stored. It is accessed when the `parse` function is called, which implements a different procedure based on how the experimenter saved their data.
* The `alpha` field provides further description. For example, if Caitlin stored her data in files named `Cluster_A`, `Cluster_B`, etc., then `experimenter` would be `'Caitlin'` and `alpha` would be `'A'`.
* The `analysis` field determines which analysis should be performed. `RatCatcher` doesn't actually do any real calculations, but sets up the batch files needed to run the computations on a high-performance computing cluster. It looks for somewhere on your path where a function named `[analysis '.batchFunction']` is. This `batchFunction` should have four arguments: `filename, cellnum, outfile, test`. The `filename` is the absolute path to where the data are stored. The `cellnum` is a 2x1 vector that represents the tetrode/cell number for a recording. `outfile` is absolute path to the output file. `test` is a logical that flags whether this is a local or remote run.
* The `location` field contains the absolute path to where the batch and output files should be placed.
* `namespec` determines what the output files should be named.

A general use of `RatCatcher` looks something like this:

Set up your `RatCatcher` object.

```matlab
r = RatCatcher;
r.experimenter  = 'Caitlin';
r.alpha         = 'A';
r.analysis      = 'BandwidthEstimator';
r.location      = '/home/ahoyland/code/MLE-time-course/cluster';
r.namespec      = 'output-Caitlin-A';
```

Then, batch your files. They will end up in `r.location`.

```matlab
r.batchify();
```

This creates a series of batch files, a batch script (using `qsub`) that will run all these jobs on the cluster, and the output files where the data should be stored.

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

## License Information
`RatCatcher` is written by Alec Hoyland and is released under the GNU General Public License 3.0. The `natsort` functions were written by Stephen Cobeldick (c) 2018.
