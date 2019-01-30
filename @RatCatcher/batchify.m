function arg = batchify(self)

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

  % remove all old files
  delete([location filesep 'batchscript-' experimenter '-' alpha '-' analysis]);
  delete([location filesep 'filenames.txt']);
  delete([location filesep 'cellnums.csv']);

  % writes the batch scripts based on a data file known only to god (and the experimenter)
  [filename, cellnum] = self.parse();

  % save file names and cell numbers in a text file to be read out by the script
  lineWrite([location filesep 'filenames.txt'], filename);
  csvwrite([location filesep 'cellnums.csv'], cellnum);

  % copy over the new function
  copyfile(pathname, location);

  % copy over the generic script and rename
  dummyScriptName = which('RatCatcher-generic-script.sh');
  finalScriptName = [location filesep 'batchscript-' experimenter '-' alpha '-' analysis];
  copyfile(dummyScriptName, location);
  movefile(dummyScriptName, finalScriptName);

  % edit the copied script
  script          = lineRead(finalScriptName);
  outfile         = [location '/' namespec '-' '$SGE_TASK_ID' '.csv'];

  % determine the name of the job array
  strrep(script, 'BATCH_NAME', [experimenter '-' alpha '-' analysis]);

  % determine the number of jobs
  strrep(script, 'NUM_FILES', num2str(length(filename)));

  % determine the argument to MATLAB
  strrep(script, 'ARGUMENT', ['$SGE_TASK_ID' ',' location ',' outfile ',' 'false']);

end % function
