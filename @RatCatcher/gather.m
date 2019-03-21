function dataTable = gather(self, filekey, dataTable0)

  % GATHER collects data from RATCATCHER output files and forms a data table
  %
  %   dataTable = r.GATHER()
  %
  %   dataTable = r.GATHER(filekey)
  %
  %   dataTable = r.GATHER(filekey, dataTable0)
  %
  % If gather is called with no arguments except the RatCatcher object
  % filekey defaults to [r.namespec '*']
  % filekey is passed to the DIR function which searches in r.localPath
  % and therefore uses normal wildcard searching syntax
  %
  % If the third argument is a table, new data is appended, building the table.
  % Otherwise, a new table is instead generated.
  %
  % If filekey is a cell array, this function operates recursively to build the data table.
  %
  % See also RATCATCHER, RATCATCHER.BATCHIFY, RATCATCHER.STITCH, DIR

  localPath = self.localPath;
  protocol  = self.protocol;
  namespec  = self.namespec;

  % assume that the output files are stored sensibly
  if isempty(namespec)
    namespec = 'output';
    disp('[INFO] Assuming namespec is: output-')
  end

  if ~exist('filekey', 'var')
    filekey = [namespec '*'];
    disp(['[INFO] Assuming filekey is: ' filekey])
  end

  % filekey is a cell, operate recursively over filekeys
  if iscell(filekey)

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
  if ~isempty(localPath)
    cd(localPath)
  end

  % gather together all of the data points into a single matrix
  % find all of the files matching the namespec pattern
  files     = dir(filekey);
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
