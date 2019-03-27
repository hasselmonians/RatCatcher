function batchify(self, batchname, filenames0, filecodes0, pathname0, verbose)

  % BATCHIFY generates batch scripts indicated by a RatCatcher object
  %   r.BATCHIFY batches the files specified by the ratcatcher object
  %
  %   r.BATCHIFY(batchname)
  %     uses a custom batchname rather than one generated from RATCATCHER.GETBATCHNAME
  %
  %   r.BATCHIFY(batchname, filenames, filecodes)
  %     overrides using RATCATCHER.PARSE to find the filenames and filecodes
  %     filenames should be a cell array, filecodes should be an n x 2 matrix
  %
  %   r.BATCHIFY(batchname, filenames, filecodes, pathname)
  %     overrides using RATCATCHER.PARSE and provides a custom batch function
  %     pathname should be a character vector (path to the function)
  %
  %   r.BATCHIFY(batchname, filenames, filecodes, pathname, false)
  %     does not display verbose display text
  %
  % If batchname, filenames0, filecodes0, or pathname0 are empty [], they are skipped and the defaults are used
  % The files go into r.localPath and reference data saved in r.remotePath
  % The files are named beginning with batchscript, then by the expID and protocol
  %
  % See also RATCATCHER, RATCATCHER.PARSE, RATCATCHER.GETBATCHNAME, RATCATCHER.LISTFILES, RATCATCHER.GATHER

  %% Preamble

  if nargin < 2
    batchname = [];
  end

  if nargin < 3
    filename0 = [];
  end

  if nargin < 4
    filecodes0 = [];
  end

  if nargin < 5
    pathname0 = [];
  end

  if nargin < 6
    verbose = true;
  end


  % if the filename and filecodes have been given by the user, override
  % otherwise, find the filenames and filecodes using the parse function

  if ~isempty(filenames0)
    filenames = filename0;

    if verbose == true
      disp[('[INFO] filenames determined by user')]
    end

  end

  if ~isempty(filecodes)
    filecodes = filecodes0;

    if verbose == true
      disp[('[INFO] filecodes determined by user')]
    end

  end

  if isempty(filenames0) & isempty(filecodes0) & isempty(self.filenames)
    % unpackage variables
    filenames = self.filenames;
    filecodes = self.filecodes;

    if verbose == true
      disp('[INFO] filenames and filecodes determined from RatCatcher object')
    end

  else
    % use parse to determine filenames and filecodes
    [filenames, filecodes] = self.parse();
  end

  % save configuration in RatCatcher object
  self.filenames = filenames;
  self.filecodes = filecodes;

  if verbose == true
    disp[('[INFO] parsed filenames and filecodes')]
  end

  % if the path to the batch function has been given by the user, override
  % otherwise, find the batch function by searching

  if ~isempty(pathname0)
    pathname = pathname0;

    if verbose == true
      disp[('[INFO] batch function determined by user')]
    end

  else
    pathname = which([self.protocol '.batchFunction']);

    if numel(pathname) == 0
      disp(['[ERROR] batch function not found at: ' fullfile(self.protocol '.batchFunction')])
      return
    end

    if verbose == true
      disp[('[INFO] batch function found')]
    end

  end % pathname

  % define shorthand variables
  filenames   = self.filenames;
  expID       = self.expID;
  remotePath  = self.remotePath;
  localPath   = self.localPath;
  protocol    = self.protocol;
  project     = self.project;
  tt          = '''';

  % define the batchname
  if ~isempty(batchname)
    batchname   = RatCatcher.getBatchName(expID, protocol);
  end

  if verbose == true
    disp(['[INFO] batch name is: ' batchname])
  end

  %% Clean out the directory

  warning off all
  delete(fullfile(localPath, ['*', batchname, '*']))
  warning on all

  if verbose == true
    disp('[INFO] all old files removed')
  end

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
  copyfile(pathname, localPath);

  if verbose == true
    disp(['[INFO] batch function copied to: ' localPath])
  end

  % copy over the generic script and rename
  dummyScriptName = 'RatCatcher-generic-script.sh';
  % find the dummy script by using a lazy hack
  dummyScriptPath = which(dummyScriptName);
  % name the batch script using the same format as the filenames and filecodes
  finalScriptPath = fullfile(localPath, [batchname, '.sh']);
  copyfile(dummyScriptPath, finalScriptPath);

  if verbose == true
    disp(['[INFO] batch script copied to: ' finalscriptpath])
  end

  %% Edit the copied batch file

  % useful variables
  script    = filelib.read(finalScriptPath);
  outfile   = fullfile(remotePath, [batchname, '-', 'SGE_TASK_ID', '.csv']);

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
  figlib.write(finalScriptPath, script);

  if verbose == true
    disp('[INFO] batch script edited')
  end

  if verbose == true
    disp('[INFO] DONE!')
  end

  disp('[INFO] pass this script to qsub as an argument:')


end % function
