classdef RatCatcher

properties

  expID
  % character vector or cell array of character vectors
  % cannot be a character matrix
  % an unambiguous identifier that identifies the raw data
  % it serves as a code to the `parse` function
  % the columns are increasingly specific IDs to the parse function
  % the rows are new IDs (results are appended)

  remotepath@char
  % character vector
  % absolute path to where the output data should be stored on a computing cluster

  localpath@char
  % character vector
  % absolute path to where the output data should be stored on a local computer

  protocol@char
  % character vector
  % the name of the analysis protocol to be performed on the cluster
  % this is used to find the correct batchFunction

  project@char
  % character vector
  % the name of the project paying for compute nodes on the cluster

  batchname@char
  % the unique identifier which is part of every file name for files created by RatCatcher

  filenames
  % m x 1 cell array of character vectors
  % the list of files names of raw data to be processed via the batch function

  filecodes
  % a matrix of size m x n, where m is the number of filenames
  % contains numerical information used to find specific data inside of the paired filename

  batchfuncpath@char
  % character vector
  % the full path to the batch function
  % used to select the correct batch function during batchifying

  batchscriptpath@char
  % character vector
  % the full path to the batch script
  % used to select the correct batch script during batchifying

  verbose@logical = true
  % logical
  % if true, functions output more descriptive text while running

  parallel@logical = false
  % logical
  % if true, try to use a parallelized batch function for increased speed



end % properties

methods

  function self = RatCatcher()
    try
      p = RatCatcher.pref();
      expID = p.expID;
      remotepath = p.remotepath;
      localpath = p.localpath;
      protocol = p.protocol;
      project = p.project;
    end
  end % function

end % methods

methods (Static)

  % both of these methods naturally sort, that is, by separating the name into syntactic phrases and then sorting hierarchically...for example, 'output-11' comes before 'output-21' when naturally sorted
  [X,ndx,dbg] = natsort(X,xpr,varargin)
  [X,ndx,dbg] = natsortfiles(X,varargin)
  [protocolObject, dataObject] = extract(dataTable, index, analysis, verbose)
  [p] = pref()
  [filename, cellnum] = read(location, batchname, index)
  [filenames] = getFileNames(identifiers, filesig, masterpath)
  [bin_start, bin_finish, pc, parpool_tmpdir] = getParallelOptions(bin_id, bin_total, location, batchname)

end % static methods

end % classdef
