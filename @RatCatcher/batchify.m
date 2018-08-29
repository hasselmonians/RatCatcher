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

  % Good fortune on your adventure
  returnToCWD = pwd;

  % find the path to the analysis batch function
  pathname = which([analysis '.batchFunction']);
  if numel(pathname) == 0
    disp('[ERROR] I don''t know which analysis you mean.')
    return
  end

  % writes the batch scripts based on a data file known only to god (and the experimenter)
  [filename, cellnum] = self.parse();

  % remove all old files
  delete([location filesep 'batch*']);
  % copy over the new function
  copyfile(pathname, location);

  % move to where the batch files should be saved
  if ~isempty(location)
    cd(location)
  end

  % write the batch files
  arg = cell(length(filename), 1);
  for ii = 1:length(filename)
    outfile = [namespec '-' num2str(ii) '.csv'];
    csvwrite(outfile, []);
    infile = ['batch-' num2str(ii)];
    fileID  = fopen(infile, 'w');
    fprintf(fileID, '#!/bin/csh\n');
    fprintf(fileID, 'module load matlab/2017a\n');
    fprintf(fileID, '#$ -l h_rt=72:00:00\n');
    arg{ii} = ['batchFunction(''' filename{ii} ''', [' num2str(cellnum(ii, 1)) ' ' num2str(cellnum(ii, 2)) '], ''' location '/' outfile ''', false);'];
    fprintf(fileID, ['matlab -nodisplay -r "' arg{ii} ' exit;"']);
    fclose(fileID);
  end

  % add a qsub file
  fileID = fopen('batchFile.sh', 'w');
  log = '/projectnb/hasselmogrp/hoyland/MLE-time-course/cluster/log/';
  err = '/projectnb/hasselmogrp/hoyland/MLE-time-course/cluster/err/';
  for ii = 1:length(filename)
    fprintf(fileID, ['qsub -pe omp 16 -o ' log ' -e ' err ' -P ' 'hasselmogrp ' './batch-' num2str(ii) '\n']);
  end
  fclose(fileID);

  % Brave traveler, you may rest now, once more before the hearth of your home
  cd(returnToCWD);

end % function
