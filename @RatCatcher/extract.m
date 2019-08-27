function [protocolObject, dataObject] = extract(dataTable, index, protocol, verbose)
  % extracts the raw data and builds an protocol object
  % Arguments:
    % dataTable: the table built by RatCatcher.gather where the data information are stored
      % should be indexed already (e.g. be a 1 x n table)
      % if not, the index argument indexes for you
    % protocol: a character vector that describes which protocol object to build
    % index: a scalar index that tells you how to index the datafile
  % Outputs:
    % protocolObject: the struct produced by the protocol method
    % dataObject: the root (Session) object specified by the dataTable and index

  if size(dataTable, 1) == 1
    % if dataTable is 1 x n
    index = 1;
  else
    % if dataTable is m x n
    assert(exist('index', 'var') && isscalar(index), 'If dataTable is an m x n table, then index should be a positive integer.')
  end

  if nargin < 3
      protocol = 'BandwidthEstimator';
      verbose  = false;
  elseif isempty(protocol)
      protocol = 'BandwidthEstimator';
  end

  % load the data file
  if verbose, disp('[INFO] load the data file'); end
  load(dataTable.filenames{index});
  root            = root.AppendKalmanVel;
  root            = root.FixTime;
  dataObject      = root;
  % process the data file
  dataObject.cel  = dataTable.filecodes(index, :);

  % determine next step based on protocol method
  corelib.verb(verbose, 'RatCatcher::extract', 'setting up protocol object')
  switch protocol
  case 'BandwidthEstimator'
    protocolObject = BandwidthEstimator(dataObject);
  otherwise
    disp('[ERROR] I don''t know which protocol method you mean')
  end % switch

end % function
