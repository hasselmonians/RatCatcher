function self = validate(self)

  % validates secondary properties of RatCatcher prior to batchifying

  % batch name

  if isempty(self.batchname)
    % no additional information specified by user
    % finding the batch name automatically

    self.batchname = self.getBatchName();

    if self.verbose
      disp('[INFO] batch name determined automatically')
    end

  else
    % batch name was preset by the user

    if self.verbose
      disp('[INFO] batch name determined by user')
    end

  end

  % filenames and filecodes

  if isempty(self.filenames) & isempty(self.filecodes)
    % no additional information specified by user
    % finding filenames and filecodes automatically
    [self.filenames, self.filecodes] = self.parse();

    if self.verbose
      disp('[INFO] filenames and filecodes determined automatically')
    end

  else

    if self.verbose
      disp('[INFO] filenames and filecodes determined by user')
    end

  end

  % batch function name

  if isempty(self.batchfuncpath)
    % no additional information specified by user
    % finding the batch function name automatically
    self.batchfuncpath = self.getBatchFuncPath();

    if isempty(self.batchfuncpath)
      % couldn't find the batch function name automatically
      % error

      if self.verbose
        disp('[ERROR] batch function name not found')
        return
      end

    else
      % batch function name was found automatically

      if self.verbose
        disp(['[INFO] batch function name determined automatically'])
      end

    end

  else
    % the batch function name was already provided

    if self.verbose
      disp(['[INFO] batch function name determined by user'])
    end

  end

  % batch script name

  if isempty(self.batchscriptpath)
    % batch script is not provided by user
    % determine automatically
    self.batchscriptpath = self.getBatchScriptPath();

    if self.verbose == true
      disp(['[INFO] batch script determined automatically'])
    end

  else
    if self.verbose == true
      disp('[INFO] batch script determined by user')
    end
  end

  if numel(which(self.batchscriptpath)) == 0
    error(['[ERROR] batch function not found at: ' self.batchscriptpath])
  end

  % check all properties to confirm they exist
  props = properties(self);

  for prop = props
    if isempty(self.(prop))
      error(['[ERROR] ' prop 'property is empty'])
    end
  end

end % function
