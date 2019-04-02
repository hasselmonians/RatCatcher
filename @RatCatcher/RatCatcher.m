classdef RatCatcher

properties

  % filenames
  % cell array of character vectors
  % a list of all filenames of the raw data to be processed
  % note that these could be folders which unambiguously specify an experiment
  % since some experiments produce multiple data files (e.g. a video and time series data)

  % filecodes
  % numerical matrix of size n x 2 where n = length(filenames)
  % stores any additional parameters required to unambiguously specific data
  % from one of the filenames

  expID
  % character vector or cell array of character vectors
  % an unambiguous identifier that identifies the raw data
  % it serves as a code to the |parse| function
  % the columns are increasingly specific IDs to the parse function
  % the rows are new IDs (results are appended)

  remotePath
  % character vector
  % absolute path to where the output data should be stored on a computing cluster

  localPath
  % character vector
  % absolute path to where the output data should be stored on a local computer

  protocol
  % character vector
  % the name of the analysis protocol to be performed on the cluster
  % this is used to find the correct batchFunction

  project
  % character vector
  % the name of the project paying for compute nodes on the cluster

end % properties

methods

  function self = RatCatcher()
    if exist(fullfile('RatCatcher', '@RatCatcher', 'pref.m'), 'file')
      p = RatCatcher.pref();
      filenames = p.filenames;
      expID = p.expID;
      remotePath = p.remotePath;
      localPath = p.localPath;
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
  [filename, cellnum] = read(location, batchName, index)
  [filenames] = listFiles(identifiers, filesig, masterpath)
  [output] = getBatchName(expID, protocol)

end % static methods

end % classdef
