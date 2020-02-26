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


  %% Preamble

  expID     = self.expID;
  localpath = self.localpath;
  protocol  = self.protocol;

  if ~exist('filekey', 'var')
    filekey = [];
  end

  %% Generate the filekey

  % check the batchname property first
  if isempty(filekey)
    if isempty(self.batchname)
      filekey = self.getBatchScriptName();
      for ii = 1:length(filekey)
        filekey{ii} = ['output-' filekey{ii} '*'];
      end
      corelib.verb(self.verbose, 'RatCatcher::gather', ['filekey determined automatically: ' filekey])
    else
      filekey = self.batchname;
      if iscell(filekey)
        for ii = 1:length(filekey)
          filekey{ii} = ['output-' filekey{ii} '*'];
        end
      else
        filekey = ['output-' filekey '*'];
      end
      corelib.verb(self.verbose, 'RatCatcher::gather', ['filekey set by batchname property'])
    end
  else
    corelib.verb(self.verbose, 'RatCatcher::gather', ['filekey set by user: ' filekey])
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

  %% Gather the data files

  % set out for an epic journey, but always remember your home
  returnToCWD = pwd;

  % move to where the output files are stored
  if ~isempty(localpath)
    cd(localpath)
  else
    corelib.verb(self.verbose, 'RatCatcher::gather', ['No local path set, not changing directories'])
  end

  % gather together all of the data points into a single matrix
  % find all of the files matching the namespec pattern
  files     = dir(filekey);

  % exit early if no files can be found
  if numel(files) == 0
    dataTable = table();
    corelib.verb(self.verbose, 'RatCatcher::gather', ['no files found with filekey: ' '''' filekey ''''])
    return
  end

  % acquire the outfiles
  outfiles  = {files.name};
  % sort the outfiles in a sensible manner
  outfiles  = self.natsortfiles(outfiles);
  % get the dimensions of the data
  dim1      = length(outfiles);
  % read through the files and write the data to a matrix
  data      = NaN([dim1 size(readmatrix(outfiles{1}))]);
  corelib.verb(self.verbose, 'RatCatcher::gather', 'reading outfiles to build data matrix')

  %% Collect the data from the outfiles

  if self.verbose
    for ii = 1:dim1
      corelib.textbar(ii, dim1)
      data(ii, :) = corelib.vectorise(readmatrix(outfiles{ii}));
    end
  else
    for ii = 1:dim1
      data(ii, :) = corelib.vectorise(readmatrix(outfiles{ii}));
    end
  end

  %% Package the data depending on the protocol

  switch protocol
  case 'BandwidthEstimator'
    corelib.verb(self.verbose, 'RatCatcher::gather', ['protocol ' protocol ' identified'])
    % gather the data from the output files
    kmax    = data(:, 1);
    CI      = data(:, 2:3);
    kcorr   = data(:, 4);
    % put the data in a MATLAB table
    dataTable = table(outfiles, kmax, CI, kcorr);
  case 'KiloPlex'
    corelib.verb(self.verbose, 'RatCatcher::gather', ['protocol ' protocol ' identified'])
    % the data are a bunch of .mat files, so just gather the names of the files
    dataTable = table(outfiles);
  case 'CellSorter'
    corelib.verb(self.verbose, 'RatCatcher::gather', ['protocol ' protocol ' identified'])
    % the data are waveforms in a 50x4 matrix
    % the first index is over time steps of the recording
    % the second index is over channels in a tetrode
    % the units are milliseconds
    waveforms = cell(dim1, 1);
    spike_width = NaN(dim1, 1);
    firing_rate = NaN(dim1, 1);
    for ii = 1:dim1
      waveforms{ii} = squeeze(data(ii, :, 1:end-1));
      spike_width(ii) = squeeze(data(ii, 1, end));
      firing_rate(ii) = squeeze(data(ii, 2, end));
    end
    dataTable = table(waveforms, spike_width, firing_rate);
  case 'NeuralDecoder'
    corelib.verb(self.verbose, 'RatCatcher::gather', ['protocol ' protocol ' identified'])
    % collect the parameter vectors by parameter name
    alpha   = data(:, 1, 1);
    mu      = data(:, 1, 2);
    sigma   = data(:, 1, 3);
    tau     = data(:, 1, 4);
    % concatenate into a table
    dataTable = table(alpha, mu, sigma, tau);
case {'LightDark', 'DarkLight', 'LaserControl'}
    corelib.verb(self.verbose, 'RatCatcher::gather', ['protocol ' protocol ' identified'])
    % collect the parameter vectors by parameter name
    l2d_h      = data(:, 1);
    d2l_h      = data(:, 2);
    l2d_p      = data(:, 3);
    d2l_p      = data(:, 4);
    l2d_tstat  = data(:, 5);
    d2l_tstat  = data(:, 6);
    l2d_df     = data(:, 7);
    d2l_df     = data(:, 8);
    % concatenate into a table
    dataTable = table(l2d_h, l2d_p, l2d_tstat, l2d_df, d2l_h, d2l_p, d2l_tstat, d2l_df);
  case {'LightDark2', 'DarkLight2'}
    warn('this protocol is currently unavailable, try LightDark2.gather or DarkLight2.gather instead')
    corelib.verb(self.verbose, 'RatCatcher::gather', ['protocol ' protocol ' identified'])
    % timestamps is the first row
    timestamps = data(1, :);
    % padded_spike_counts is the matrix less 1 on each side
    spike_counts = data(2:end, 1:end-1);
    dataTable = table(timestamps, spike_counts);
  otherwise
    corelib.verb(true, 'RatCatcher::gather', 'I don''t know which protocol you mean.')
  end

  %% Cleanup

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
