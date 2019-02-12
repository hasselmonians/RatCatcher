function finalScriptPath = batchify(self, verbose)

  % BATCHIFY generates batch scripts indicated by a RatCatcher object
  %   finalScriptPath = r.BATCHIFY batches the files specified by the ratcatcher object
  %
  %   finalScriptPath = r.BATCHIFY(false) does not display verbose display text
  %
  % The files go into r.localPath and reference data saved in r.remotePath
  % The files are named ['batchscript-' r.namespec '-' r.experimenter '-' r.alphanumeric '-' r.analysis '.sh']
  %
  % See also RATCATCHER, RATCATCHER.PARSE

  if nargin < 2
    verbose = true;
  end

  experimenter  = self.experimenter;
  alphanumeric  = self.alphanumeric;
  analysis      = self.analysis;
  localPath     = self.localPath;
  remotePath    = self.remotePath;
  namespec      = self.namespec;

  % for multiple alphanumerics stored in a cell array, operate recursively
  if iscell(self.alphanumeric)
    for ii = 1:length(self.alphanumeric)
      self.alphanumeric = alphanumeric{ii};
      self.batchify(verbose);
    end
    self.alphanumeric = alphanumeric;
    return
  end


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
  delete([localPath filesep 'batchscript-' experimenter '-' alphanumeric '-' analysis '.sh']);
  delete([localPath filesep 'filenames-' experimenter '-' alphanumeric '-' analysis '.txt']);
  delete([localPath filesep 'cellnums-' experimenter '-' alphanumeric '-' analysis '.csv']);
  warning on all

  if verbose == true
    disp('[INFO] all old files removed')
  end

  % writes the batch scripts based on a data file known only to god (and the experimenter)
  [filename, cellnum] = self.parse();

  % save file names and cell numbers in a text file to be read out by the script
  lineWrite([localPath filesep 'filenames-' experimenter '-' alphanumeric '-' analysis '.txt'], filename);
  csvwrite([localPath filesep 'cellnums-' experimenter '-' alphanumeric '-' analysis '.csv'], cellnum);

  if verbose == true
    disp('[INFO] filenames and cell numbers parsed')
  end

  % copy over the new function
  copyfile(pathname, localPath);

  if verbose == true
    disp('[INFO] batch function copied to localPath')
  end

  % copy over the generic script and rename
  dummyScriptName = 'RatCatcher-generic-script.sh';
  dummyScriptPath = which(dummyScriptName);
  finalScriptPath = [localPath filesep 'batchscript-' experimenter '-' alphanumeric '-' analysis '.sh'];
  copyfile(dummyScriptPath, finalScriptPath);

  if verbose == true
    disp('[INFO] batch script copied to localPath')
  end

  % edit the copied script
  script          = lineRead(finalScriptPath);
  outfile         = [remotePath '/' namespec '-' experimenter '-' alphanumeric '-' analysis '-' '$SGE_TASK_ID' '.csv'];

  % determine the name of the job array
  script = strrep(script, 'BATCH_NAME', ['''' experimenter '-' alphanumeric '-' analysis '''']);

  % determine the number of jobs
  script = strrep(script, 'NUM_FILES', num2str(length(filename)));

  % determine the argument to MATLAB
  script = strrep(script, 'ARGUMENT', ['$SGE_TASK_ID' ', ' '''' remotePath '''' ', ' '''' outfile '''' ', ' 'false']);

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
