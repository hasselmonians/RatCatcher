function finalScriptPath = batchify(self, verbose)

  % automatically generates batch files for mouse or rat data
  % Arguments:
    % experimenter: expects either 'Holger' or 'Caitlin'
    % alpha: the alphanumeric identifier for the experimentalist's data
    % for experimenter = 'Caitlin', this should be an ID from cluster_info.mat
    % e.g. 'A' or 'B', etc.
    % analysis: character vector, determines which batch function is found and where the data goes
    % location: character vector, the relative or absolute path to where the batch files should go
    % namespec: character vector, determines what the output files should be called
    % they take the form "namespec-#.csv"
  % Outputs:
    % arg: n x 1 cell of character vectors, contains the matlab command to run the batchFunction

  if nargin < 2
    verbose = true;
  end

  experimenter  = self.experimenter;
  alpha         = self.alpha;
  analysis      = self.analysis;
  location      = self.location;
  namespec      = self.namespec;

  % find the path to the analysis batch function
  pathname = which([analysis '.batchFunction']);
  if numel(pathname) == 0
    disp('[ERROR] I don''t know which analysis you mean.')
    return
  end

  if verbose == true
    disp('[INFO] analysis batch function found')
  end

  % remove all old files
  warning off all
  delete([location filesep 'batchscript-' experimenter '-' alpha '-' analysis]);
  delete([location filesep 'filenames.txt']);
  delete([location filesep 'cellnums.csv']);
  warning on all

  if verbose == true
    disp('[INFO] all old files removed')
  end

  % writes the batch scripts based on a data file known only to god (and the experimenter)
  [filename, cellnum] = self.parse();

  % save file names and cell numbers in a text file to be read out by the script
  lineWrite([location filesep 'filenames.txt'], filename);
  csvwrite([location filesep 'cellnums.csv'], cellnum);

  if verbose == true
    disp('[INFO] filenames and cell numbers parsed')
  end

  % copy over the new function
  copyfile(pathname, location);

  if verbose == true
    disp('[INFO] batch function copied to location')
  end

  % copy over the generic script and rename
  dummyScriptName = 'RatCatcher-generic-script.sh';
  dummyScriptPath = [location filesep dummyScriptName];
  finalScriptPath = [location filesep 'batchscript-' experimenter '-' alpha '-' analysis];
  copyfile(which(dummyScriptName), location);
  movefile(dummyScriptPath, finalScriptPath);

  if verbose == true
    disp('[INFO] batch script copied to location')
  end

  % edit the copied script
  script          = lineRead(finalScriptPath);
  outfile         = [location '/' namespec '-' '$SGE_TASK_ID' '.csv'];

  % determine the name of the job array
  script = strrep(script, 'BATCH_NAME', ['''' experimenter '-' alpha '-' analysis '''']);

  % determine the number of jobs
  script = strrep(script, 'NUM_FILES', num2str(length(filename)));

  % determine the argument to MATLAB
  script = strrep(script, 'ARGUMENT', ['$SGE_TASK_ID' ', ' '''' location '''' ', ' '''' outfile '''' ', ' 'false']);

  % write to file
  lineWrite(finalScriptPath, script);

  if verbose == true
    disp('[INFO] batch script edited')
  end

  if verbose == true
    disp('[INFO] DONE!')
  end

  if nargout == 0
    disp('[INFO] pass this script to qsub as an argument:')
    disp(finalScriptPath)
  end

end % function
