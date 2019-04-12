function batchify(self)

  % BATCHIFY generates batch scripts indicated by a RatCatcher object
  %   r.BATCHIFY batches the files specified by the ratcatcher object
  %
  % The files go into r.localpath and reference data saved in r.remotepath
  % The files are named beginning with batchscript, then by the expID and protocol
  %
  % See also RATCATCHER, RATCATCHER.PARSE, RATCATCHER.VALIDATE, RATCATCHER.GATHER

  %% Parse all of the inputs

  self        = self.validate();

  % define shorthand variables
  expID       = self.expID;
  remotepath  = self.remotepath;
  localpath   = self.localpath;
  protocol    = self.protocol;
  project     = self.project;
  tt          = '''';
  batchname   = self.batchname;
  filenames   = self.filenames;
  filecodes   = self.filecodes;
  batchfuncpath  = self.batchfuncpath;
  batchscriptpath  = self.batchscriptpath;
  verbose     = self.verbose;

  %% Cleanup and lamplighting

  % TODO: write a better delete script
  warning off all
  % delete(fullfile(localpath, ['*', batchname, '*']))
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
  filelib.write(fullfile(localpath, ['filenames-' batchname '.txt']), filenames);
  % write filecodes.csv
  csvwrite(fullfile(localpath, ['filecodes-' batchname, '.csv']), filecodes);

  if verbose == true
    disp('[INFO] filenames and filecodes parsed')
  end

  % copy over the new batch function
  copyfile(batchfuncpath, localpath);

  if verbose == true
    disp(['[INFO] batch function copied to: ' localpath])
  end

  %% Copy over the generic script and rename

  % find the dummy script by using a lazy hack
  dummyScriptPath = which(batchscriptpath);
  % name the batch script using the same format as the filenames and filecodes
  finalScriptPath = fullfile(localpath, [batchname, '.sh']);
  copyfile(dummyScriptPath, finalScriptPath);

  if verbose == true
    disp(['[INFO] batch script copied to: ' finalScriptPath])
  end

  %% Edit the copied batch file

  % useful variables
  script    = filelib.read(finalScriptPath);
  outfile   = fullfile(remotepath, [batchname, '-', 'SGE_TASK_ID', '.csv']);

  % TODO: make outfile more robust (accept more output types)

  % determine the name of the job array
  script    = strrep(script, 'BATCH_NAME', batchname);

  % determine the project name on the cluster
  script    = strrep(script, 'PROJECT_NAME', project);

  % determine the number of jobs
  script    = strrep(script, 'NUM_FILES', num2str(length(filenames)));

  % determine the argument to MATLAB
  script    = strrep(script, 'ARGUMENT', ['$SGE_TASK_ID' ', ' ...
                    tt remotepath tt ', ' ...
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
