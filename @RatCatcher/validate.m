function self = validate(self)

  % validates secondary properties of RatCatcher prior to batchifying
  % If you want to fully flesh out your RatCatcher object but *not* batch it,
  % use this function

  % Example:
  % r = r.validate;

  % batch name

  if isempty(self.batchname)
    % no additional information specified by user
    % finding the batch name automatically
    self.batchname = self.getBatchScriptName();
    corelib.verb(self.verbose, 'RatCatcher::validate', 'batch name determined automatically')

  else
    % batch name was preset by the user
    corelib.verb(self.verbose, 'RatCatcher::validate', 'batch name already set')

  end

  % filenames and filecodes

  if isempty(self.filenames) & isempty(self.filecodes)
    % no additional information specified by user
    % finding filenames and filecodes automatically
    [self.filenames, self.filecodes] = self.parse();
    corelib.verb(self.verbose, 'RatCatcher::validate', 'filenames and filecodes determined automatically')

  else
    corelib.verb(self.verbose, 'RatCatcher::validate', 'filenames and filecodes already set')

  end

  % batch function name

  if isempty(self.batchfuncpath)
    % no additional information specified by user
    % finding the batch function name automatically
    self.batchfuncpath = self.getBatchFuncPath();

    if isempty(self.batchfuncpath)
      % couldn't find the batch function name automatically
      % error
      corelib.verb(self.verbose, 'RatCatcher::validate', 'ERROR: could not find the batch function name automatically')
      return

    else
      % batch function name was found automatically
      corelib.verb(self.verbose, 'RatCatcher::validate', 'batch function name determined automatically')
    end

  else
    % the batch function name was already provided
    corelib.verb(self.verbose, 'RatCatcher::validate', 'batch function name already set')

  end

  % batch script name

  if isempty(self.batchscriptpath)
    % batch script is not provided by user
    % determine automatically
    self.batchscriptpath = self.getBatchScriptPath();
    corelib.verb(self.verbose, 'RatCatcher::validate', 'batch script determined automatically')

  else
    corelib.verb(self.verbose, 'RatCatcher::validate', 'batch script already set')

  end

  if numel(which(self.batchscriptpath)) == 0
    error(['[ERROR] batch function not found at: ' self.batchscriptpath])
  end

  % verbosity

  if isempty(self.verbose)
    self.verbose = true;
  end

  % check all properties to confirm they exist
  props = properties(self);
  for ii = 1:length(props)
    if isempty(self.(props{ii}))
      corelib.verb(true, 'RatCatcher::validate', ['WARN: ' props{ii} ' property is empty'])
    end
  end

  % nbins

  switch self.mode
  case 'parallel'
    if isempty(self.nbins)
      self.nbins = self.getNBins();
      corelib.verb(self.verbose, 'RatCatcher::validate', 'nbins determined automatically')
    else
      corelib.verb(self.verbose, 'RatCatcher::validate', 'nbins already set')
    end
  otherwise
      % do nothing
  end

end % function
