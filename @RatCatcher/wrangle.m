function [varargout] = wrangle(filenames_file, varargin)

    %% Arguments
    %   filenames_file: path to a text file with a .mat filename on each line
    %       files are expected to have been saved on the shared computing cluster (SCC)
    %       see: https://github.com/hasselmonians/knowledge-base/wiki/Connecting-to-the-SCC#mounting-the-ssc-on-a-local-computer
    %
    %% Outputs
    %   filenames: an n x 1 cell array of filenames
    %       each filename is copied to match with the filecodes associated with it
    %   filecodes: an n x 2 matrix of filecodes (cell number & tetrode number)
    %
    %% Examples
    %
    % [options] = wrangle()
    %
    % [filenames, filecodes, file_missing] = wrangle(filenames_file, 'Name', Value, ...)
    %
    %% Notes
    % this function requires access to the cluster at /mnt/hasselmogrp
    % see: https://github.com/hasselmonians/knowledge-base/wiki/Connecting-to-the-SCC#mounting-the-ssc-on-a-local-computer
    % as usual, this function also requires https://github.com/sg-s/srinivas.gs_mtools/

    %% Preamble

    options = struct;
    options.Verbosity   = false; % true or false
    options.SavePath    = ''; % if filled, save the outputs here

    options = orderfields(options);

    if ~nargin & nargout
        varargout{1} = options;
        return
    end

    options = corelib.parseNameValueArguments(options, varargin{:});

    %% Load the filenames file

    loaded_filenames = filelib.read(filenames_file);

    % if saved with an empty last line, strip that off
    if isempty(loaded_filenames{end})
        loaded_filenames = loaded_filenames(1:end-1);
    end

    %% Load each .mat file

    filenames = {};
    filecodes = [];

    file_missing = false(length(loaded_filenames), 1);

    for ii = 1:length(loaded_filenames)
        try
            % parse the filename and load the .mat file
            this_filename = strrep(loaded_filenames{ii}, 'projectnb', 'mnt');
            load(this_filename)

            % extract an n x 2 matrix of cell numbers
            these_filecodes = root.cells;

            % update the filenames cell array
            for qq = 1:size(these_filecodes, 1)
                filenames{end+1} = this_filename;
            end

            % update the filecodes matrix
            filecodes((end+1):(end+size(these_filecodes, 1)), :) = these_filecodes;

            corelib.verb(options.Verbosity, 'grid-cell-spiking/wrangle', 'success!')
        catch
            file_missing(ii) = true;
            corelib.verb(options.Verbosity, 'grid-cell-spiking/wrangle', 'file missing!')
        end
    end

    %% Output

    if ~isempty(options.SavePath)
        filelib.write([options.SavePath, filesep, 'filenames.txt'], filenames);
        writematrix(filecodes, [options.SavePath, filesep, 'filecodes.csv']);
    end

    varargout{1} = filenames;
    varargout{2} = filecodes;
    varargout{3} = file_missing;
