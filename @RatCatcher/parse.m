function [filenames, filecodes] = parse(self)
  % parses the name of a datafile listed within cluster_info.mat
  % extracts the main section of the filenames and the cell index
  %
  % Arguments:
  %
  % self: expects a RatCatcher object with the expID field
  %
  % Outputs:
  %
  % filenames: cell array or character vector containing the filenames specified
  %   if expID is 1 x n, the cell array contains character vectors of the full file paths
  %   if expID is m x n, the cell array contains cell arrays of character vectors of the full file paths
  %
  % filecodes: cell array or matrix containing the filecodes specified
  %   if expID is 1 x n, the cell array contains matrix of the numerical identifiers
  %   if expID is m x n, the cell array contains cell arrays of matrix of the numerical identifiers
  %
  % See also: RatCatcher, RatCatcher.batchify, RatCatcher.listFiles

  expID = self.expID;

  if iscell(expID)
    if size(expID, 1) ~= 1
      % expID is a cell array with multiple sets (i.e. rows)
      % construct the filenames and filecodes lists by reading each row
      filenames = cell(size(expID, 1), 1);
      filecodes = cell(size(expID, 1), 1);
      for ii = 1:size(expID, 1)
        % iterate through the parsing and add each cell array to the cell array
        [filenames{ii}, filecodes{ii}] = parse_core(expID(ii,:), self.verbose);
      end
    else
      % if expID is a row vector cell array or a scalar cell array
      [filenames, filecodes] = parse_core(expID(1,:), self.verbose);
    end
  else
    % if expID is a character vector
    [filenames, filecodes] = parse_core({expID}, self.verbose);
  end

end % function
