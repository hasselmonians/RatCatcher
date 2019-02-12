function [filename, cellnum] = parse(self)
  % parses the name of a datafile listed within cluster_info.mat
  % extracts the main section of the filename and the cell index

  % Arguments:
    % expects a fully-specified RatCatcher object
  % Outputs:
    % filename: n x 1 cell, the parsed filenames for where the data are stored
    % cellnum: n x 2 double, the recording/cell indices corresponding to the filenames

  % if self.alphanumeric is a character vector, run this function once
  % if self.alphanumeric is a cell array, run this function iteratively
  % and append the results to the output

  experimenter  = self.experimenter;
  alphanumeric         = self.alphanumeric;

  if iscell(alphanumeric)
    if ~isscalar(alphanumeric)
      % if alphanumeric is a cell array
      [filename, cellnum] = parse_core(experimenter, alphanumeric{1});
      for ii = 2:length(alphanumeric)
        % iterate through the parsing and append the results
        [filename0, cellnum0] = parse_core(experimenter, alphanumeric{ii});
        filename  = [filename; filename0];
        cellnum   = [cellnum; cellnum0];
      end
    else
      % if alphanumeric is a scalar cell
      [filename, cellnum] = parse_core(experimenter, alphanumeric{1});
    end
  else
    % alphanumeric should be a character vector
    [filename, cellnum] = parse_core(experimenter, alphanumeric);
  end

end % function

function [filename, cellnum] = parse_core(experimenter, alphanumeric)
  % accepts an experimenter and alphanumeric just like parse; performs the core function
  % parse calls this function a number of times depending on its inputs
  switch experimenter
  case 'Caitlin'
    % load the cluster info file
    try
      load('/projectnb/hasselmogrp/hoyland/cluster_info.mat');
    catch
      try
        load('/mnt/hasselmogrp/hoyland/cluster_info.mat');
      catch
        try
          load(which('cluster_info.mat'));
        catch
          error('[ERROR] Cluster info could not be found.');
        end
      end
    end

    % get the cluster name
    cluster         = eval(['Cluster_' alphanumeric]);
    stringParts     = cell(1, 2);
    filename        = cell(length(cluster.RowNodeNames), 1);
    cellcell        = cell(length(cluster.RowNodeNames), 1);

    % split the cluster row node names into experiment and recording/cell names
    for ii = 1:length(cluster.RowNodeNames)
      stringParts   = strsplit(cluster.RowNodeNames{ii}, '_cell_');
      filename{ii}  = stringParts{1};
      cellcell{ii}  = stringParts{2};
    end

    % parse the filenames
    old             = {'bender-', 'calculon-', 'clamps-', 'cm-19-', 'cm-20-', 'cm-41-', 'cm-47-', 'cm-48-', 'cm-51-', 'nibbler-', 'zoidberg-'};
    new             = {'1_', '2_', '3_', '4_', '5_', '6_', '7_', '8_', '9_', '10_', '11_'};
    for ii = 1:length(old)
      filename      = strrep(filename, old{ii}, new{ii});
    end
    for ii = 1:length(filename)
      filename{ii}  = ['/projectnb/hasselmogrp/hoyland/data/caitlin/raw/' filename{ii} '.mat'];
    end

    % parse the cellnum
    cellnum = NaN(length(cellcell), 2);
    for ii = 1:length(cellcell)
      splt = strsplit(cellcell{ii}, '-');
      for qq = 1:size(cellnum, 2)
        cellnum(ii, qq) = str2num(splt{qq});
      end
    end

  case 'Holger'
    error('[ERROR] I don''t know what to do yet.')
  otherwise
    error('[ERROR] I don''t know which experimenter you mean.')
  end % end switch

end % function
