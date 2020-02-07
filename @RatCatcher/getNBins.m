function nbins = getNBins(self)

    % determines the number of bins used for parallelized array jobs
    % assumes that the number of cores is 16
    %
    %% Arguments:
    % self: a RatCatcher object
    %
    %% Outputs:
    % nbins: a scalar if self.expID is a character vector or cell array row vector
    %   a vector if self.expID is a cell array column vector or matrix
    %   is empty if self.mode is not 'parallel'
    %
    %% Example:
    %
    %   nbins = self.getNBins();
    %

    nThreads = 16;

    if strcmp(self.mode, 'parallel')
        if iscell(self.expID)
            % expID is a cell array
            if size(self.expID, 1) > 1
                % expID is a cell array with multiple rows
                % nbins is a vector
                nbins = NaN(size(self.expID, 1), 1);
                % iterate through expID row-wise to generate the number of bins
                for ii = 1:size(self.expID, 1)
                    nbins(ii) = ceil(length(self.filenames{ii}) / nThreads);
                end
            else
                % expID is a single row cell array
                % nbins is a scalar
                nbins = ceil(length(self.filenames) / nThreads);
            end
        else
            % expID is a character vector
            % nbins is a scalar
            nbins = ceil(length(self.filenames) / nThreads);
        end
    else
        nbins = [];
    end

end % function
