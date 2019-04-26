function self = batchify(self)

  % BATCHIFY generates batch scripts indicated by a RatCatcher object
  %   r.BATCHIFY batches the files specified by the ratcatcher object
  %
  % The files go into r.localpath and reference data saved in r.remotepath
  % The files are named beginning with batchscript, then by the expID and protocol
  %
  % See also RATCATCHER, RATCATCHER.PARSE, RATCATCHER.VALIDATE, RATCATCHER.GATHER

  %% Parse all of the inputs

  self        = self.validate();

  %% Cleanup and lamplighting

  % perform lamplighting
  lamplit_filepaths = self.lamplight();

  % erase old files
  self.clean(lamplit_filepaths);

  %% Add to the directory

  % copy over the new batch function
  copyfile(self.batchfuncpath, self.localpath);
  corelib.verb(self.verbose, 'INFO', ['batch function copied to: ' self.localpath])

  % save file names and cell numbers in a text file to be read out by the script
  % this format is a standard -- it will be referenced in the batch function as well

  % write filenames.txt
  filelib.write(fullfile(self.localpath, ['filenames-' self.batchname '.txt']), self.filenames);
  % write filecodes.csv
  csvwrite(fullfile(self.localpath, ['filecodes-' self.batchname, '.csv']), self.filecodes);

  corelib.verb(self.verbose, 'INFO', 'filenames and filecodes parsed')


  %% Copy over the generic script and rename

  % find the dummy script by using a lazy hack
  dummyScriptPath = which(self.batchscriptpath);

  for ii = 1:size(self.batchname, 1)

    % name the batch script using the same format as the filenames and filecodes
    finalScriptPath = fullfile(self.localpath, ['batchscript-', self.batchname{ii}, '.sh']);
    copyfile(dummyScriptPath, finalScriptPath);
    corelib.verb(self.verbose, 'INFO', ['batch script copied to: ' finalScriptPath])

    %% Edit the copied batch file

    % useful variables
    script    = filelib.read(finalScriptPath);
    outfile   = fullfile(self.remotepath, ['output-', self.batchname{ii}, '-', 'SGE_TASK_ID', '.csv']);

    % TODO: make outfile more robust (accept more output types)

    % determine the name of the job array
    script    = strrep(script, 'BATCH_NAME', self.batchname{ii});

    % determine the project name on the cluster
    script    = strrep(script, 'PROJECT_NAME', project);

    % determine the number of jobs
    script    = strrep(script, 'NUM_FILES', num2str(length(self.filenames)));

    % determine the argument to MATLAB
    script    = strrep(script, 'ARGUMENT', ['$SGE_TASK_ID' ', ' ...
                      tt self.remotepath tt ', ' ...
                      tt self.batchname{ii} tt ', ' ...
                      tt outfile tt ', ' ...
                      'false']);

    % write to file
    filelib.write(finalScriptPath, script);
  end

  corelib.verb(self.verbose, 'INFO', 'batch script edited')
  corelib.verb(self.verbose, 'INFO', ['run this: $ qsub ' self.remotepath filesep 'batchscript-', self.batchname, '.sh'])

end % function
