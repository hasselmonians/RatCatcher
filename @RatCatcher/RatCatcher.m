classdef RatCatcher

properties

  filenames
  % cell array of character vectors
  % a list of all filenames of the raw data to be processed

  expID
  % character vector
  % an unambiguous identifier that identifies the raw data
  % it serves as a code to the |parse| function

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
  [analysisObject, dataObject] = extract(dataTable, index, analysis, verbose)
  [p] = pref()
  [filename, cellnum] = read(location, batchName, index)
  [filenames] = rebase(identifiers, filesig, masterpath)

end % static methods

end % classdef
