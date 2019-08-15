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
      filekey = self.getBatchScriptName();
      for ii = 1:length(filekey)
        filekey{ii} = ['output-' filekey{ii} '*'];
      end
      corelib.verb(self.verbose, 'gather', ['filekey determined automatically: ' filekey])
    else
      filekey = self.batchname;
      if iscell(filekey)
        for ii = 1:length(filekey)
          filekey{ii} = ['output-' filekey{ii} '*'];
        end
      else
        filekey = ['output-' filekey '*'];
      end
      corelib.verb(self.verbose, 'gather', ['filekey set by batchname property'])
    end
  else
    corelib.verb(self.verbose, 'gather', ['filekey set by user: ' filekey])
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
      qq = 1;
      for ii = 1:length(filekey)
        fk = filekey{ii};
        if ii == qq
          dataTable = self.gather(fk);
          if isempty(dataTable)
            qq = qq + 1;
          end
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
    disp(['[gather] No local path set, not changing directories'])
  end

  % gather together all of the data points into a single matrix
  % find all of the files matching the namespec pattern
  files     = dir(filekey);

  if numel(files) == 0
    dataTable = table();
    corelib.verb(self.verbose, 'gather', 'no files found with filekey')
  else
    % acquire the outfiles
    outfiles  = cell(size(files));
    for ii = 1:length(files)
      outfiles{ii} = files(ii).name;
    end
    % sort the outfiles in a sensible manner
    outfiles  = self.natsortfiles(outfiles);
    % get the dimensions of the data
    dim1      = length(outfiles);
    % read through the files and write the data to a matrix
    data      = NaN([dim1 size(csvread(outfiles{1}))]);
    corelib.verb(self.verbose, 'gather', 'reading outfiles to build data matrix')

    if self.verbose
      for ii = 1:dim1
        corelib.textbar(ii, dim1)
        data(ii, :) = corelib.vectorise(csvread(outfiles{ii}));
      end
    else
      for ii = 1:dim1
        data(ii, :) = corelib.vectorise(csvread(outfiles{ii}));
      end
    end

    switch protocol
    case 'BandwidthEstimator'
      corelib.verb(self.verbose, 'gather', ['protocol ' protocol ' identified'])
      % gather the data from the output files
      kmax    = data(:, 1);
      CI      = data(:, 2:3);
      kcorr   = data(:, 4);
      % put the data in a MATLAB table
      dataTable = table(outfiles, kmax, CI, kcorr);
    case 'KiloPlex'
      corelib.verb(self.verbose, 'gather', ['protocol ' protocol ' identified'])
      % the data are a bunch of .mat files, so just gather the names of the files
      dataTable = table(outfiles);
    case 'CellSorter'
      corelib.verb(self.verbose, 'gather', ['protocol ' protocol ' identified'])
      % the data are waveforms in a 50x4 matrix
      % the first index is over time steps of the recording
      % the second index is over channels in a tetrode
      % the units are milliseconds
      waveforms = {data};
      dataTable = table(waveforms);
    otherwise
      corelib.verb(true, 'gather', 'I don''t know which protocol you mean.')
    end
  end

  % return from whence you came
  cd(returnToCWD)

  % append to extant data table, if there is one
  if exist('dataTable0') && ~isempty(dataTable0)
    if ~isempty(dataTable)
      dataTable = [dataTable0; dataTable];
    else

      dataTable = dataTable0;
    end
  end

end % function
