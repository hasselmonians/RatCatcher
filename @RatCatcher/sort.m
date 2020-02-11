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

    %% Preamble

    if iscell(self.filenames) || iscell(self.filecodes)
        disp('[RatCatcher::sort] this function does not yet operate on cells, aborting...')
        return
    end

    %% Sort the filenames
    [self.filenames, I] = sort(self.filenames);
    self.filecodes = self.filecodes(I);

end % function
