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

  % find the dummy script by using a lazy hack
  dummyScriptPath = which(self.batchscriptpath);

  % copy over the new batch function
  if ~exist(self.localpath, 'dir')
    mkdir(self.localpath);
  end
  copyfile(self.batchfuncpath, self.localpath);
  corelib.verb(self.verbose, 'RatCatcher::batchify', ['batch function copied to: ' self.localpath])

  %% Set up scripts

  % if self.batchname is a cell array, make a script for each contained character vector
  if iscell(self.batchname)
    for ii = 1:length(self.batchname)
      batchify_core(self, self.batchname{ii}, self.filenames{ii}, self.filecodes{ii}, dummyScriptPath);
      corelib.verb(self.verbose, 'RatCatcher::batchify', 'batch script edited')
      corelib.verb(self.verbose, 'RatCatcher::batchify', ['run this: $ qsub ' self.remotepath filesep 'batchscript-', self.batchname{ii}, '.sh'])
    end
  else
    batchify_core(self, self.batchname, self.filenames, self.filecodes, dummyScriptPath);
    corelib.verb(self.verbose, 'RatCatcher::batchify', 'batch script edited')
    corelib.verb(self.verbose, 'RatCatcher::batchify', ['run this: $ cd ' self.remotepath '; qsub ' 'batchscript-', self.batchname, '.sh'])
  end


end % function

function batchify_core(self, batchname, filenames, filecodes, dummyScriptPath)
  tt = '''';

  % save file names and cell numbers in a text file to be read out by the script
  % this format is a standard -- it will be referenced in the batch function as well

  % write filenames.txt
  filelib.write(fullfile(self.localpath, ['filenames-' batchname '.txt']), filenames);

  % write filecodes.csv
  csvwrite(fullfile(self.localpath, ['filecodes-' batchname, '.csv']), filecodes);
  corelib.verb(self.verbose, 'RatCatcher::batchify', 'filenames and filecodes parsed')

  % name the batch script using the same format as the filenames and filecodes
  finalScriptPath = fullfile(self.localpath, ['batchscript-', batchname, '.sh']);
  copyfile(dummyScriptPath, finalScriptPath);
  corelib.verb(self.verbose, 'RatCatcher::batchify', ['batch script copied to: ' finalScriptPath])

  %% Edit the copied batch file

  % useful variables
  script    = filelib.read(finalScriptPath);

  % TODO: make outfile more robust (accept more output types)

  %% Determine the name of the job array

  script    = strrep(script, 'BATCH_NAME', batchname);

  %% Determine the project name on the cluster

  script    = strrep(script, 'PROJECT_NAME', self.project);

  %% Determine the number of jobs

  % set the number of files (occurs for parallel and array jobs)
  script    = strrep(script, 'NUM_FILES', num2str(length(filenames)));
  % set the number of bins (occurs for only parallel jobs)
  script    = strrep(script, 'NUM_BINS', num2str(self.nbins));

  %% Add flags if necessary

  % whether to use a single computational thread
  % is determined by the 'threading' property
  switch self.threading
  case 'single'
      script = strrep(script, 'FLAGS', '-singleCompThread');
      script = strrep(script, 'THREADS', '');
  case 'multi'
      script = strrep(script, 'FLAGS', '');
      script = strrep(script, 'THREADS', '#$ -pe omp 16');
  end

  %% Determine the argument to MATLAB batch function

  switch self.mode
  case 'array'
    outfile   = fullfile(self.remotepath, ['output-', batchname, '-', '$SGE_TASK_ID']);
    script  = strrep(script, 'ARGUMENT', ['$SGE_TASK_ID' ', ' ...
              tt self.remotepath tt ', ' ...
              tt batchname tt ', ' ...
              tt outfile tt ', ' ...
              'false']);
  case 'parallel'
    outfile   = fullfile(self.remotepath, ['output-', batchname]);
    script  = strrep(script, 'ARGUMENT', ['$SGE_TASK_ID' ', ' ...
              '$SGE_TOTAL_BINS' ',' ...
              tt self.remotepath tt ', ' ...
              tt batchname tt ', ' ...
              tt outfile tt ', ' ...
              'false']);
  otherwise
      outfile = fullfile(self.remotepath, ['output-', batchname]);
      script  = strrep(script, 'ARGUMENT', [...
                tt self.remotepath tt ', ' ...
                tt batchname tt ', ' ...
                tt outfile tt ', ' ...
                'false']);
  end

  % write to file
  filelib.write(finalScriptPath, script);
end % function
