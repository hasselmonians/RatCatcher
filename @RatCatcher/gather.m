function dataTable = gather(self)

  % gathers up data from a series of output files

  % Arguments:
    % location: character vector, the path to the output files
    % analysis: character vector, describes the type of gathering performed
      % expects 'BandwidthEstimator' or ???
    % namespec: character vector, is the non-unique identifier for output files
    % for example if your files are named output-1 output-2 etc.
    % then the namespec is 'output-'
  % Outputs:
    % dataTable: m x n table, a MATLAB data table, specific to the analysis

    location = self.location;
    analysis = self.analysis;
    namespec = self.namespec;

  % assume that the output files are stored sensibly
  if isempty(namespec)
    namespec = 'output-';
    disp('[INFO] Assuming namespec is ''output-''')
  end

  % set out for an epic journey, but always remember your home
  returnToCWD = pwd;

  % move to where the output files are stored
  if ~isempty(location)
    cd(location)
  end

  % gather together all of the data points into a single matrix
  % find all of the files matching the namespec pattern
  files     = dir([namespec '*']);
  % acquire the outfiles
  outfiles = cell(size(files));
  for ii = 1:length(files)
    outfiles{ii} = files(ii).name;
  end
  % sort the outfiles in a sensible manner
  outfiles = self.natsortfiles(outfiles);
  % get the dimensions of the data
  dim1      = length(outfiles);
  dim2      = length(csvread(outfiles{1}));
  % read through the files and write the data to a matrix
  data      = NaN(dim1, dim2);
  for ii = 1:dim1
    data(ii, :) = csvread(outfiles{ii});
  end

  switch analysis
  case 'BandwidthEstimator'
    % gather the data from the output files
    kmax    = data(:, 1);
    CI      = data(:, 2:3);
    % put the data in a MATLAB table
    dataTable = table(outfiles, kmax, CI);
  otherwise
    disp('[ERROR] I don''t know which analysis you mean.')
  end

  % return from whence you came
  cd(returnToCWD)

end % function
