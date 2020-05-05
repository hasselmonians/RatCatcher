function [varargin] = extract(data_table, varargin)

  %% Description
  %   extracts the raw data and builds a protocol object
  %
  %% Arguments:
    % data_table: 1 x n or m x n table, the table built by RatCatcher.gather where the data information are stored
      % should be indexed already (e.g. be a 1 x n table)
      % if not, the Index argument indexes for you
    % varargin
    %   either a struct of options
    %   or name-value argument pairs
    % protocol: a character vector that describes which protocol object to build
    % preprocess_fcn: a function handle that operates on data_table.filenames(index) before loading the data
    %   example: preprocess_fcn = @(x) strrep(x, 'projectnb', 'mnt')
    % verbose: a boolean flag for how much info text to print
    %
  %% Outputs:
    % protocolObject: the struct produced by the protocol method
    % dataObject: the root (Session) object specified by the data_table and index
    %
  %% Examples:
  %   options = RatCatcher.extract()
  %
  %   [protocolObject, dataObject] = RatCatcher.extract(data_table, 'Protocol', 'BandwidthEstimator')
  % 
  %   [protocolObject, dataObject] = RatCatcher.extract(data_table, ...
  %     'Protocol', 'BandwidthEstimator', ...
  %     'Index', 1, ...
  %     'PreProcessFcn', @(x) strrep(x, 'projectnb', 'mnt'), ...
  %     'Verbosity', true)
  %
  %% See Also: RatCatcher/index, RatCatcher/gather, RatCatcher/stitch

  %% Preamble

  options = struct;
  options.Index         = 1; % logical scalar, linear index into data table
  options.Protocol      = []; % character vector, the RatCatcher protocol
  options.PreprocessFcn = []; % function handle, how to parse raw data filenames before loading
  options.Verbosity     = false; % logical scalar, how much info text to print

  options = orderfields(options);

  if ~nargin & nargout
    varargout{1} = options;
    return
  end

  options = corelib.parseNameValueArguments(options, varargin{:});

  % parse Index
  if size(data_table, 1) == 1
    % then data_table is size 1 x n
    options.Index = 1;
  else
    % then data_table is size m x n
    assert(isscalar(options.Index), 'Index must be a positive integer')
    assert(options.Index > 0, 'Index must be a positive integer')
  end

  %% Load the data

  corelib.verb(verbose, 'RatCatcher::extract', 'loading the data file')

  if isempty(options.PreProcessFcn)
    load(data_table.filenames{options.Index});
  else
    load(options.PreProcessFcn(data_table.filenames{options.Index}));
  end

  % post-process the loaded CMBHOME object
  root            = root.AppendKalmanVel;
  root            = root.FixTime;
  dataObject      = root;

  % process the data file
  dataObject.cel  = data_table.filecodes(options.Index, :);

  % determine next step based on protocol method
  corelib.verb(options.Verbosity, 'RatCatcher::extract', 'setting up protocol object')

  switch options.Protocol
  case 'BandwidthEstimator'
    protocolObject = BandwidthEstimator(dataObject);
  case 'NeuralDecoder'
    protocolObject = NeuralDecoder(dataObject);
  otherwise
    disp('[ERROR] I don''t know which protocol method you mean')
  end % switch

  %% Outputs

  varargin{1} = protocolObject;
  varargin{2} = dataObject;

end % function
