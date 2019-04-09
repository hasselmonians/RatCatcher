function batchify(self)

  % BATCHIFY generates batch scripts indicated by a RatCatcher object
  %   r.BATCHIFY batches the files specified by the ratcatcher object
  %
  % If batchname, filenames, filecodes, batchfuncname, or scriptname are empty [], they are skipped and the defaults are used
  % The files go into r.localPath and reference data saved in r.remotePath
  % The files are named beginning with batchscript, then by the expID and protocol
  %
  % See also RATCATCHER, RATCATCHER.PARSE, RATCATCHER.GETBATCHNAME, RATCATCHER.LISTFILES, RATCATCHER.GATHER

  %% Preamble

  % define shorthand variables
  expID       = self.expID;
  remotePath  = self.remotePath;
  localPath   = self.localPath;
  protocol    = self.protocol;
  project     = self.project;
  tt          = '''';
  batchname   = self.batchname;
  filenames   = self.filenames;
  filecodes   = self.filecodes;
  batchfuncname  = self.batchfuncname;
  scriptname  = self.scriptname;
  verbose     = self.verbose;

  %% Parse all of the inputs

  % define the batchname
  if isempty(batchname)
    batchname   = RatCatcher.getBatchName(expID, protocol);
  end

  if verbose == true
    disp(['[INFO] batch name is: ' batchname])
  end

  % if the filename and filecodes have been given by the user, override
  % otherwise, find the filenames and filecodes using the parse function

  if isempty(filenames) & isempty(filecodes)
    % no additional information specified by user
    % finding filenames and filecodes automatically
    [filenames, filecodes] = self.parse();
    if verbose == true
      disp('[INFO] filenames and filecodes determined automatically')
    end
  else
    disp('[INFO] filenames and filecodes determined by user')
  end

  % if the path to the batch function has been given by the user, override
  % otherwise, find the batch function by searching

  if isempty(batchfuncname)
    batchfuncname = which([protocol '.batchFunction']);
  else
    if verbose == true
      disp('[INFO] batch function determined by user')
    end
  end

  if numel(batchfuncname) == 0
    error(['[ERROR] batch function not found at: ' [fullfile(protocol) '.batchFunction']])
  end

  if verbose == true
    disp('[INFO] batch function found')
  end

  % determine the script name
  if isempty(scriptname)
    scriptname = 'RatCatcher-generic-script.sh';
    if verbose == true
      disp(['[INFO] batch script determined automatically'])
    end
  else
    if verbose == true
      disp('[INFO] batch script determined by user')
    end
  end

  if numel(which(scriptname)) == 0
    error(['[ERROR] batch function not found at: ' scriptname])
  end

  %% Cleanup and lamplighting

  % TODO: write a better delete script
  warning off all
  % delete(fullfile(localPath, ['*', batchname, '*']))
  warning on all

  if verbose == true
    disp('[INFO] all old files removed')
  end

  % perform lamplighting
  self.lamplight();

  %% Add to the directory

  % save file names and cell numbers in a text file to be read out by the script
  % this format is a standard -- it will be referenced in the batch function as well

  % write filenames.txt
  filelib.write(fullfile(localPath, ['filenames-' batchname '.txt']), filenames);
  % write filecodes.csv
  csvwrite(fullfile(localPath, ['filecodes-' batchname, '.csv']), filecodes);

  if verbose == true
    disp('[INFO] filenames and filecodes parsed')
  end

  % copy over the new batch function
  copyfile(batchfuncname, localPath);

  if verbose == true
    disp(['[INFO] batch function copied to: ' localPath])
  end

  %% Copy over the generic script and rename

  % find the dummy script by using a lazy hack
  dummyScriptPath = which(scriptname);
  % name the batch script using the same format as the filenames and filecodes
  finalScriptPath = fullfile(localPath, [batchname, '.sh']);
  copyfile(dummyScriptPath, finalScriptPath);

  if verbose == true
    disp(['[INFO] batch script copied to: ' finalScriptPath])
  end

  %% Edit the copied batch file

  % useful variables
  script    = filelib.read(finalScriptPath);
  outfile   = fullfile(remotePath, [batchname, '-', 'SGE_TASK_ID', '.csv']);

  % TODO: make outfile more robust (accept more output types)

  % determine the name of the job array
  script    = strrep(script, 'BATCH_NAME', batchname);

  % determine the project name on the cluster
  script    = strrep(script, 'PROJECT_NAME', project);

  % determine the number of jobs
  script    = strrep(script, 'NUM_FILES', num2str(length(filenames)));

  % determine the argument to MATLAB
  script    = strrep(script, 'ARGUMENT', ['$SGE_TASK_ID' ', ' ...
                    tt remotePath tt ', ' ...
                    tt batchname tt ', ' ...
                    tt outfile tt ', ' ...
                    'false']);

  % write to file
  filelib.write(finalScriptPath, script);

  if verbose == true
    disp('[INFO] batch script edited')
  end

  if verbose == true
    disp('[INFO] DONE!')
  end

  disp('[INFO] pass this script to qsub as an argument:')


end % function
