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

function [bin_start, bin_finish] = getParallelOptions(bin_id, bin_total, location, batchname)

  % get the total number of files
  total_iterations = length(filelib.read(fullfile(location, ['filenames-', batchname, '.txt']))) - 1;

  % get the size of each bin
  bin_size = ceil(total_iterations / bin_total);

  % get the starting point of the bin
  bin_start = bin_size * (bin_id - 1) + 1;

  % get the ending point of the bin
  bin_finish = bin_size * bin_id;

  if bin_finish > total_iterations
    bin_finish = total_iterations;
  end

end % function
