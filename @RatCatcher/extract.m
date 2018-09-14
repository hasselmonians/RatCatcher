function [analysisObject, dataObject] = extract(dataTable, index, analysis, verbose)
  % extracts the raw data and builds an analysis object
  % Arguments:
    % dataTable: the table built by RatCatcher.gather where the data information are stored
      % should be indexed already (e.g. be a 1 x n table)
      % if not, the index argument indexes for you
    % analysis: a character vector that describes which analysis object to build
    % index: a scalar index that tells you how to index the datafile
  % Outputs:
    % analysisObject: the struct produced by the analysis method
    % dataObject: the root (Session) object specified by the dataTable and index

  if size(dataTable, 1) == 1
    % if dataTable is 1 x n
    index = 1;
  else
    % if dataTable is m x n
    assert(exist('index', 'var') && isscalar(index), 'If dataTable is an m x n table, then index should be a positive integer.')
  end

  if nargin < 3
      analysis = 'BandwidthEstimator';
      verbose  = false;
  elseif isempty(analysis)
      analysis = 'BandwidthEstimator';
  end

  % load the data file
  if verbose, disp('[INFO] load the data file'); end
  load(dataTable.filenames{index});
  root            = root.AppendKalmanVel;
  dataObject      = root;
  % process the data file
  dataObject.cel  = dataTable.cellnums(index, :);

  % determine next step based on analysis method
  if verbose, disp('[INFO] set up analysis object'); end
  switch analysis
  case 'BandwidthEstimator'
    analysisObject = BandwidthEstimator(dataObject);
  otherwise
    disp('[ERROR] I don''t know which analysis method you mean')
  end % switch

end % function
