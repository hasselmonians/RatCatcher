function dataTable = gather(self, filekey, dataTable0)

  % GATHER collects data from RATCATCHER output files and forms a data table
  %
  %   dataTable = r.GATHER()
  %     assumes a filekey acquired from RATCATCHER.GETBATCHSCRIPTNAME
  %
  %   dataTable = r.GATHER(filekey)
  %     uses a custom filekey
  %
  %   dataTable = r.GATHER([], dataTable0)
  %     assumes a filekey and adds to an extant data table
  %
  %   dataTable = r.GATHER(filekey, dataTable0)
  %     uses a custom filekey and adds to an extant data table
  %
  % If gather is called with no arguments except the RatCatcher object
  % filekey defaults to what's recovered with r.GETBATCHSCRIPTNAME
  % filekey is passed to the DIR function which searches in r.localpath
  % and therefore uses normal wildcard searching syntax
  %
  % If dataTable0 is not empty and is a table, new data is appended, building the table.
  % Otherwise, a new table is instead generated.
  %
  % In order for GATHER to work correctly, it needs to have options set for the
  % specified PROTOCOL.
  %
  % If filekey is a cell array, this function operates recursively to build the data table.
  %
  % See also RATCATCHER, RATCATCHER.BATCHIFY, RATCATCHER.STITCH, RATCATCHER.GETBATCHSCRIPTNAME, DIR

  expID     = self.expID;
  localpath = self.localpath;
  protocol  = self.protocol;

  if nargin < 2
    filekey = [];
  end

  if isempty(filekey)
    % check the batchname property first
    if isempty(self.batchname)
      filekey = ['output-' self.getBatchScriptName '*'];
      corelib.verb(self.verbose, 'INFO', ['filekey determined automatically: ' filekey])
    else
      filekey = self.batchname;
      corelib.verb(self.verbose, 'INFO', ['filekey set by batchname property'])
    end      
  else
    corelib.verb(self.verbose, 'INFO', ['filekey set by user: ' filekey])
  end

  if iscell(filekey)
    % filekey is a cell, operate recursively over filekeys

    if exist('dataTable0', 'var')
      dataTable = dataTable0;
      for ii = 1:length(filekey)
        fk = filekey{ii};
        dataTable = self.gather(fk, dataTable);
      end
      return

    else
      for ii = 1:length(filekey)
        fk = filekey{ii};
        if ii == 1
          dataTable = self.gather(fk);
        else
          dataTable = self.gather(fk, dataTable);
        end
      end
      return

    end
  end

  % set out for an epic journey, but always remember your home
  returnToCWD = pwd;

  % move to where the output files are stored
  if ~isempty(localpath)
    cd(localpath)
  else
    disp(['[INFO] No local path set, not changing directories'])
  end

  % gather together all of the data points into a single matrix
  % find all of the files matching the namespec pattern
  files     = dir(filekey);
  
  if numel(files) == 0
    corelib.verb(true, 'ERROR', 'no files found with filekey')
    cd(returnToCWD)
    return
  end
  
  % acquire the outfiles
  outfiles  = cell(size(files));
  for ii = 1:length(files)
    outfiles{ii} = files(ii).name;
  end
  % sort the outfiles in a sensible manner
  outfiles  = self.natsortfiles(outfiles);
  % get the dimensions of the data
  dim1      = length(outfiles);
  dim2      = length(csvread(outfiles{1}));
  % read through the files and write the data to a matrix
  data      = NaN(dim1, dim2);
  for ii = 1:dim1
    data(ii, :) = csvread(outfiles{ii});
  end

  switch protocol
  case 'BandwidthEstimator'
    % gather the data from the output files
    kmax    = data(:, 1);
    CI      = data(:, 2:3);
    kcorr   = data(:, 4);
    % put the data in a MATLAB table
    dataTable = table(outfiles, kmax, CI, kcorr);
  case 'KiloPlex'
    % the data are a bunch of .mat files, so just gather the names of the files
    dataTable = table(outfiles);
  otherwise
    disp('[ERROR] I don''t know which protocol you mean.')
  end

  % return from whence you came
  cd(returnToCWD)

  % append to extant data table, if there is one
  if exist('dataTable0') && ~isempty(dataTable0)
    dataTable = [dataTable0; dataTable];
  end

end % function
