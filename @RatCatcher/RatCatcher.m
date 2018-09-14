classdef RatCatcher

properties

  % experimenter: a character vector that identifies where the data are stored
  % and how to parse the data files to extract relevant information
  % for example, 'Caitlin'
  experimenter
  % alpha: a character vector or cell array that identifies in greater specificity where the data are stored and how to parse the data files. For example, Caitlin's data has been stored in .mat files with filenames 'Cluster_A.mat', 'Cluster_B.mat', ... so alpha is either 'A' ... or {'A', 'B', ...}.
  % in general, if alpha is a cell array, function will loop over each value of alpha and return
  % appended outputs
  alpha
  % analysis: a character vector specifying the type of analysis this RatCatcher object will expect
  % generally, this is important for setting up the proper batch files
  % so far, only 'BandwidthEstimator' works
  analysis
  % location: where the output files should be stored after running a batch
  location
  % namespec: what these output files should be named
  % for example, 'output-' is a great generic namespec
  namespec

end % properties

methods

end % methods

methods (Static)

  % both of these methods naturally sort, that is, by separating the name into syntactic phrases and then sorting hierarchically...for example, 'output-11' comes before 'output-21' when naturally sorted
  [X,ndx,dbg] = natsort(X,xpr,varargin)
  [X,ndx,dbg] = natsortfiles(X,varargin)
  [analysisObject, dataObject] = extract(dataTable, index, analysis, verbose)

end % static methods

end % classdef
