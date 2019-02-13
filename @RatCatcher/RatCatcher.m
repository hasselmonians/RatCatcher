classdef RatCatcher

properties

  % experimenter: a character vector that identifies where the data are stored
  % and how to parse the data files to extract relevant information
  % for example, 'Caitlin'
  experimenter
  % alphanumeric: a character vector or cell array that identifies in greater specificity where the data are stored and how to parse the data files. For example, Caitlin's data has been stored in .mat files with filenames 'Cluster_A.mat', 'Cluster_B.mat', ... so alphanumeric is either 'A' ... or {'A', 'B', ...}.
  % in general, if alphanumeric is a cell array, function will loop over each value of alphanumeric and return
  % appended outputs
  alphanumeric
  % analysis: a character vector specifying the type of analysis this RatCatcher object will expect
  % generally, this is important for setting up the proper batch files
  % so far, only 'BandwidthEstimator' works
  analysis
  % localPath: the path to where the data are stored from your local computer
  % if your computer has a storage cluster mounted, it's the path to the data on the cluster
  % remotePath: the path to where the data is on the cluster, if you were starting on the cluster
  localPath
  remotePath
  % namespec: what these output files should be named
  % for example, 'output' is a great generic namespec
  namespec

end % properties

methods

  function self = RatCatcher()
    if exist(which('RatCatcher.pref'), 'file')
      p = RatCatcher.pref();
      self.experimenter = p.experimenter;
      self.alphanumeric = p.alphanumeric;
      self.analysis = p.analysis;
      self.localPath = p.localPath;
      self.remotePath = p.remotePath;
      self.namespec = p.namespec;
    end
  end % function

end % methods

methods (Static)

  % both of these methods naturally sort, that is, by separating the name into syntactic phrases and then sorting hierarchically...for example, 'output-11' comes before 'output-21' when naturally sorted
  [X,ndx,dbg] = natsort(X,xpr,varargin)
  [X,ndx,dbg] = natsortfiles(X,varargin)
  [analysisObject, dataObject] = extract(dataTable, index, analysis, verbose)
  [p]         = pref()
  [filename, cellnum] = read(location, batchName)

end % static methods

end % classdef
