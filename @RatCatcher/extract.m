function [analysisObject, dataObject] = extract(dataTable, analysis, index)
  % extracts the raw data and builds an analysis object
  % Arguments:
    % dataTable: the table built by RatCatcher.gather where the data information are stored
      % should be indexed already (e.g. be a 1 x n table)
      % if not, the index argument indexes for you
    % analysis: a character vector that describes which analysis object to build
    % index: a scalar index that tells you how to index the datafile

  if size(dataTable, 1) ~= 1
    try
      dataTable = dataTable(index, :);
    catch err
      disp(err.message)
      disp('[ERROR] either index the dataTable (1 x n Table) or supply an index argument')
      return
  end

  % load the data file
  disp('[INFO] load the data file')
  dataObject = load(dataTable.filenames);
  % process the data file
  dataObject.cel = dataTable.cellnums;

  % determine next step based on analysis method
  switch analysis
  case 'BandwidthEstimator'
    analysisObject = BandwidthEstimator(root);
  otherwise
    disp('[ERROR] I don''t know which analysis method you mean')
  end % switch

end % function
