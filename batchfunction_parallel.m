% This is a generic batch function that is designed to take advantage of MATLAB parallelization.

function batchFunction_parallel(bin_id, bin_total, location, batchname, outfile, test)

  if ~test
    % add the proper directories to the MATLAB path
    addpath(genpath('/projectnb/hasselmogrp/hoyland/RatCatcher'))
    addpath(genpath('/projectnb/hasselmogrp/other/important/directories'))
  end

  % get the start and end times for the binned jobs
  [bin_start, bin_finish] = RatCatcher.getParallelOptions(bin_id, bin_total, location, batchname);

  % set up 'local' parallel pool cluster
  pc = parcluster('local');

  % discover the number of available cores assigned by SGE
  nCores = str2num(getenv('NSLOTS'));

  % set up directory for temporary parallel pool files
  parpool_tmpdir = ['~/.matlab/local_cluster_jobs/ratcatcher/ratcatcher_' num2str(bin_id)];
  mkdir(parpool_tmpdir);
  pc.JobStorageLocation = parpool_tmpdir;

  % start parallel pool
  parpool(pc, nCores);

  parfor ii = bin_start:bin_finish

    % set up dummy outfile variable
    outfile_pc = [outfile '-' num2str(ii) '.csv'];

    % the 'filename' is the path to your data file on the cluster
    % the 'filecode' is the associated numeric code (if any)
    [filename, filecode] = RatCatcher.read(ii, location, batchname);

    %% LOAD THE DATA %%

    % for example, if your data are saved as a CMBHOME Session object,
    % you might want to do something like this:

    % expect a 1x1 Session object named "root"
    % load(filename);
    % root.cel = filecode;

    %% YOUR CODE HERE %%

    % this is where you do any important analysis (the whole reason we're here)

    %% SAVE DATA HERE %%

    % save(outfile_pc, 'Results');

  end

% end % function
