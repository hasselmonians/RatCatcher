function [filenames, filecodes] = parse_core(expID, verbosity)
  % accepts an expID just like parse; performs the core function
  % parse calls this function a number of times depending on its inputs

  switch expID{1}

  case 'Caitlin'
    % expects expID in the form: {'Caitlin', cluster_letter}
    % load the cluster info file
    try
      load('/projectnb/hasselmogrp/ahoyland/data/caitlin/cluster_info.mat');
      corelib.verb(verbosity, 'RatCatcher::parse', ['successfully loaded filenames/codes from /projectnb/hasselmogrp/ahoyland/data/caitlin/cluster_info.mat'])
    catch
      try
        load('/mnt/hasselmogrp/ahoyland/data/caitlin/cluster_info.mat');
        corelib.verb(verbosity, 'RatCatcher::parse', ['successfully loaded filenames/codes from /mnt/hasselmogrp/ahoyland/data/caitlin/cluster_info.matt'])
      catch
        try
          load(fullfile(self.localpath, cluster_info, '.mat'));
          corelib.verb(verbosity, 'RatCatcher::parse', ['successfully loaded filenames/codes from ' fullfile(self.localpath, cluster_info, '.mat')])
        catch
          try
            if numel(which('cluster_info.mat')) == 0
              error('cluster_info.mat not found on path')
            end
            load(which('cluster_info.mat'));
            corelib.verb(verbosity, 'RatCatcher::parse', ['successfully loaded filenames/codes from' which('cluster_info.mat')])
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
      filenames{ii}  = ['/projectnb/hasselmogrp/ahoyland/data/caitlin/raw/' filenames{ii} '.mat'];
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
    % error('[ERROR] I don''t know what to do yet.')
    try
      load('/projectnb/hasselmogrp/ahoyland/data/holger/data.mat');
      corelib.verb(verbosity, 'RatCatcher::parse', ['successfully loaded filenames/codes from /projectnb/hasselmogrp/ahoyland/data/holger/data.mat'])
    catch
      try
        load('/mnt/hasselmogrp/ahoyland/data/holger/data.mat');
        corelib.verb(verbosity, 'RatCatcher::parse', ['successfully loaded filenames/codes from /mnt/hasselmogrp/ahoyland/data/holger/data.mat'])
      catch
        try
          load(fullfile(self.localpath, data, '.mat'));
          corelib.verb(verbosity, 'RatCatcher::parse', ['successfully loaded filenames/codes from ' fullfile(self.localpath, data, '.mat')])
        catch
          try
            if numel(which('data.mat')) == 0
              error('data.mat not found on path')
            end
            load(which('data.mat'));
            corelib.verb(verbosity, 'RatCatcher::parse', ['successfully loaded filenames/codes from ' which('data.mat')])
          catch
            error('[parse] data could not be found.');
          end
        end
      end
    end


  case 'Winny'
    error('[ERROR] I don''t know what to do yet.')
    % expects expID in the form: {'Winny', something}

    pathname  = ['/projectnb/hasselmogroup/winnyning/data/' expID{2}];

  case 'test'
    corelib.verb(verbosity, 'RatCatcher::parse', 'this is a test, not doing anything...')

  otherwise

    error('[ERROR] expID not processed correctly')

  end % end switch

end % functionfunction [filenames, filecodes] = parse_core(expID, verbosity)
  % accepts an expID just like parse; performs the core function
  % parse calls this function a number of times depending on its inputs

  switch expID{1}

  case 'Caitlin'
    % expects expID in the form: {'Caitlin', cluster_letter}
    % load the cluster info file
    try
      load('/projectnb/hasselmogrp/ahoyland/data/caitlin/cluster_info.mat');
      corelib.verb(verbosity, 'RatCatcher::parse', ['successfully loaded filenames/codes from /projectnb/hasselmogrp/ahoyland/data/caitlin/cluster_info.mat'])
    catch
      try
        load('/mnt/hasselmogrp/ahoyland/data/caitlin/cluster_info.mat');
        corelib.verb(verbosity, 'RatCatcher::parse', ['successfully loaded filenames/codes from /mnt/hasselmogrp/ahoyland/data/caitlin/cluster_info.matt'])
      catch
        try
          load(fullfile(self.localpath, cluster_info, '.mat'));
          corelib.verb(verbosity, 'RatCatcher::parse', ['successfully loaded filenames/codes from ' fullfile(self.localpath, cluster_info, '.mat')])
        catch
          try
            if numel(which('cluster_info.mat')) == 0
              error('cluster_info.mat not found on path')
            end
            load(which('cluster_info.mat'));
            corelib.verb(verbosity, 'RatCatcher::parse', ['successfully loaded filenames/codes from' which('cluster_info.mat')])
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
      filenames{ii}  = ['/projectnb/hasselmogrp/ahoyland/data/caitlin/raw/' filenames{ii} '.mat'];
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
    % error('[ERROR] I don''t know what to do yet.')
    try
      load('/projectnb/hasselmogrp/ahoyland/data/holger/data.mat');
      corelib.verb(verbosity, 'RatCatcher::parse', ['successfully loaded filenames/codes from /projectnb/hasselmogrp/ahoyland/data/holger/data.mat'])
    catch
      try
        load('/mnt/hasselmogrp/ahoyland/data/holger/data.mat');
        corelib.verb(verbosity, 'RatCatcher::parse', ['successfully loaded filenames/codes from /mnt/hasselmogrp/ahoyland/data/holger/data.mat'])
      catch
        try
          load(fullfile(self.localpath, data, '.mat'));
          corelib.verb(verbosity, 'RatCatcher::parse', ['successfully loaded filenames/codes from ' fullfile(self.localpath, data, '.mat')])
        catch
          try
            if numel(which('data.mat')) == 0
              error('data.mat not found on path')
            end
            load(which('data.mat'));
            corelib.verb(verbosity, 'RatCatcher::parse', ['successfully loaded filenames/codes from ' which('data.mat')])
          catch
            error('[parse] data could not be found.');
          end
        end
      end
    end


  case 'Winny'
    error('[ERROR] I don''t know what to do yet.')
    % expects expID in the form: {'Winny', something}

    pathname  = ['/projectnb/hasselmogroup/winnyning/data/' expID{2}];

  case 'test'
    corelib.verb(verbosity, 'RatCatcher::parse', 'this is a test, not doing anything...')

  otherwise

    error('[ERROR] expID not processed correctly')

  end % end switch

end % function
