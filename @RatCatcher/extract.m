function [analysisObject, dataObject] = extract(dataTable, analysis, index)
  % extracts the raw data and builds an analysis object
  % Arguments:
    % dataTable: the table built by RatCatcher.gather where the data information are stored
      % should be indexed already (e.g. be a 1 x n table)
      % if not, the index argument indexes for you
    % analysis: a character vector that describes which analysis object to build
    % index: a scalar index that tells you how to index the datafile

  if size(dataTable, 1) == 1
    % if dataTable is 1 x n
    index = 1;
  else
    % if dataTable is m x n
    assert(exist('index', 'var') && isscalar(index), 'If dataTable is an m x n table, then index should be a positive integer.')
  end

  % load the data file
  disp('[INFO] load the data file')
  load(dataTable.filenames{index});
  root            = root.AppendKalmanVel;
  dataObject      = root; delete root
  % process the data file
  dataObject.cel  = dataTable.cellnums(index, :);

  % determine next step based on analysis method
  switch analysis
  case 'BandwidthEstimator'
    analysisObject = BandwidthEstimator(dataObject);
  otherwise
    disp('[ERROR] I don''t know which analysis method you mean')
  end % switch

end % function
