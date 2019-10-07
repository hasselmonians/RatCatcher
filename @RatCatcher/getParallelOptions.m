% used in parallelized batch functions
% to set up the parallel pool

% This function is a static method of the RatCatcher class.
% It should be called within parallelized batch functions only.
% All four arguments are the same as the batch function arguments.

% Arguments:
%   bin_id: the index of where the first bin should start
%   bin_total: the number of total bins for the entire cluster run
%   location: the full path to where the cluster files are
%   batchname: the batch name for the current run
% Outputs:
%   bin_start: index in the filename list where the bin should start
%   bin_finish: index in the filename list where the bin ends
%   pc: the parallel pool cluster object
%   parpool_tmpdir: where the job files are being stored

function [bin_start, bin_finish, pc, parpool_tmpdir] = getParallelOptions(bin_id, bin_total, location, batchname)

  % get the total number of files
  total_files = length(filelib.read(fullfile(location, ['filenames-', batchname, '.txt']))) - 1;

  % get the size of each bin
  bin_size = total_files / bin_total;

  % get the starting point of the bin
  bin_start = bin_size * (bin_id - 1) + 1;

  % get the ending point of the bin
  bin_finish = bin_size * bin_id;

  % set up 'local' parallel pool cluster
  pc = parcluster('local');

  % discover the number of available cores assigned by SGE
  nCores = str2num(getenv('NSLOTS'));

  % set up directory for temporary parallel pool files
  parpool_tmpdir = ['~/.matlab/local_cluster_jobs/ratcatcher/ratcatcher_' bin_id];
  mkdir(parpool_tmpdir);
  pc.JobStorageLocation = parpool_tmpdir;

  % start parallel pool
  parpool(pc, nCores);

end % function
