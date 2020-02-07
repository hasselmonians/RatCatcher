function [filename, filecode] = read(index, location, batchname)

    % READ parses a filename file and a filecode file (generated by BATCHIFY)
    % and returns a filename as a character array and a filecode pair as a 1x2 vector
    % This is particularly useful in a batch function.
    %
    %% Arguments
    %   index: a linear index indicating the line of the filenames file to read
    %       if the index is empty, all filenames and filecodes will be returned
    %   location: the directory where the filenames file is
    %   batchname: a unique identifier for finding the correct filenames file
    %
    %% Outputs
    %   filename: the filename as a character vector
    %       if index is empty, the filename is instead a cell array of filenames
    %   filecode: the 1x2 vector of cell number and tetrode number
    %       if index is empty, all filecodes are returned in an n x 2 matrix
    %
    %% Examples
    %   Return filename and filecode for a given index
    %       [filename, filecode] = RatCatcher.READ(index, location, batchname)
    %   Return all filenames and filecodes
    %       [filenames, filecodes] = RatCatcher.read([], location, batchname)
    %
    % See also RATCATCHER, RATCATCHER.BATCHIFY

    % load the entire filename file
    % this is slow, but MATLAB has clunky textread options
    try
        filename = filelib.read(fullfile(location, ['filenames-', batchname, '.txt']));
    catch
        error(['File not found at: ' fullfile(location, ['filenames-', batchname, '.txt'])])
    end

    if ~isempty(index)
        % acquire only the character vector corresponding to the indexed filename
        filename = filename{index};
        % acquire the cell number using similarly clunky indexing
        filecode = csvread(fullfile(location, ['filecodes-', batchname, '.csv']), index-1, 0, [index-1, 0, index-1, 1]);
    else
        % return all the filenames and filecodes
        if isempty(filename{end})
            % strip off empty line at the end of file
            filename = filename(1:end-1);
        end
        filecode = readmatrix(fullfile(location, ['filecodes-', batchname, '.csv']));
    end

end % function
