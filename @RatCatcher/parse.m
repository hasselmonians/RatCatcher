function [filenames, filecodes] = parse(self)
  % parses the name of a datafile listed within cluster_info.mat
  % extracts the main section of the filenames and the cell index

  % Arguments:
    % expects a RatCatcher object with the expID field
  % Outputs:
    % filenames: n x 1 cell, the parsed filenames for where the data are stored
    % filecodes: n x m double, numerical identifiers to specify recordings within the filenames
  % if self.expID is a character vector, run this function once
  % if self.expID is a cell array, run this function iteratively
  % and append the results to the output
  %
  % See also: RatCatcher, RatCatcher.batchify, RatCatcher.listFiles

  expID = self.expID;

  if iscell(expID)
    if size(expID, 2) ~= 1
      % if expID is a cell array (e.g. contains multiple sets)
      [filenames, filecodes] = parse_core(expID(1,:));
      for ii = 2:length(expID)
        % iterate through the parsing and append the results
        [filenames0, filecodes0] = parse_core(experimenter, expID(ii,:));
        filenames  = [filenames; filenames0];
        filecodes   = [filecodes; filecodes0];
      end
    else
      % if expID is a row vector cell array or a scalar cell array
      [filenames, filecodes] = parse_core(expID(1,:));
    end
  else
    % if expID is a character vector
    [filenames, filecodes] = parse_core({expID});
  end

end % function

function [filenames, filecodes] = parse_core(expID)
  % accepts an expID just like parse; performs the core function
  % parse calls this function a number of times depending on its inputs

  switch expID{1}

  case 'Caitlin'
    % expects expID in the form: {'Caitlin', cluster_letter}
    % load the cluster info file
    try
      load('/projectnb/hasselmogrp/hoyland/cluster_info.mat');
    catch
      try
        load('/mnt/hasselmogrp/hoyland/cluster_info.mat');
      catch
        try
          load(fullfile(self.localPath, cluster_info.mat'));
        catch
          try
            load(which('cluster_info.mat'));
          catch
            error('[ERROR] Cluster info could not be found.');
          end
        end
      end
    end

    % get the cluster name
    cluster         = eval(['Cluster_' expID{2}]);
    stringParts     = cell(1, 2);
    filenames       = cell(length(cluster.RowNodeNames), 1);
    cellcell        = cell(length(cluster.RowNodeNames), 1);

    % split the cluster row node names into experiment and recording/cell names
    for ii = 1:length(cluster.RowNodeNames)
      stringParts   = strsplit(cluster.RowNodeNames{ii}, '_cell_');
      filenames{ii} = stringParts{1};
      cellcell{ii}  = stringParts{2};
    end

    % parse the filenamess
    old             = {'bender-', 'calculon-', 'clamps-', 'cm-19-', 'cm-20-', 'cm-41-', 'cm-47-', 'cm-48-', 'cm-51-', 'nibbler-', 'zoidberg-'};
    new             = {'1_', '2_', '3_', '4_', '5_', '6_', '7_', '8_', '9_', '10_', '11_'};
    for ii = 1:length(old)
      filenames      = strrep(filenames, old{ii}, new{ii});
    end
    for ii = 1:length(filenames)
      filenames{ii}  = ['/projectnb/hasselmogrp/hoyland/data/caitlin/raw/' filenames{ii} '.mat'];
    end

    % parse the filecodes
    filecodes = NaN(length(cellcell), 2);
    for ii = 1:length(cellcell)
      splt = strsplit(cellcell{ii}, '-');
      for qq = 1:size(filecodes, 2)
        filecodes(ii, qq) = str2num(splt{qq});
      end
    end

  case 'Holger'
    error('[ERROR] I don''t know what to do yet.')

  case 'Winny'
    error('[ERROR] I don''t know what to do yet.')
    % expects expID in the form: {'Winny', something}

    pathname  = ['/projectnb/hasselmogroup/winnyning/data/' expID{2}];

  otherwise

    error('[ERROR] expID not processed correctly')

  end % end switch

end % function
