% used in parallelized batch functions
% to set up the parallel pool

% Arguments:
%   bin_id:
%   bin_total:
%   location:
%   batchname:
% Outputs:
%

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
