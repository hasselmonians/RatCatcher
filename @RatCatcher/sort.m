function self = sort(self)

    %% Description:
    %   Sorts self.filenames and self.filecodes so that all filenames
    %   are next to each other.
    %   Batch functions can be written to capitalize on this by loading the filename
    %   only once per filename and iterating through the filecodes associated
    %   with a single filename.
    %   This should result in speed improvements, especially for short jobs.
    %
    %% Arguments:
    %   self: the RatCatcher object, with the filenames and filecodes properties filled out
    %
    %% Outputs:
    %   self: the RatCatcher object
    %
    %% Examples:
    %   self = r.sort();
    %
    % See Also: RatCatcher.natsortfiles, RatCatcher.getFileNames

    %% Sort the filenames

    if iscell(self.expID)
        % expID is a cell array
        if size(self.expID, 1) > 1
            % expID is a cell array with multiple rows
            % must iterate through rows of filenames/filecodes
            for ii = 1:size(self.expID, 1)
                [self.filenames{ii}, I] = sort(self.filenames{ii});
                self.filecodes{ii} = self.filecodes{ii}(I, :);
            end
        else
            % expID is a single row cell array
            [self.filenames, I] = sort(self.filenames);
            self.filecodes = self.filecodes(I, :);
        end
    else
        % expID is a character vector
        [self.filenames, I] = sort(self.filenames);
        self.filecodes = self.filecodes(I, :);
    end

end % function
