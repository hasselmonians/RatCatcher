function data = stitch(self, data)

  % stitches parsed filenames and cell numbers into datasets in the form of a table
  % if no dataset is specified, it creates a new table

  % Arguments:
    % experimenter: expects either 'Caitlin' or 'Holger'
    % alpha: the alphanumeric identifier for the experimentalist's data
    % for experimenter = 'Caitlin', this should be an ID from cluster_info.mat
    % e.g. 'A' or 'B', etc.
    % data: m x n table, the data table (probably from RatCatcher.gather)
    %   this is an optional argument
  % Outputs:
    % data: m x n+2 table, the data table


  % check to make sure that your object is up-to-date
  self = self.validate;

  % create a master list of all filenames by compressing the filenames cell structure (if any)
  % expect an n x 1 cell array of character vectors
  filenames = cat(1, self.filenames{:});

  % create a master list of all filecodes the same way
  % expect an n x m numerical matrix
  filecodes = cat(1, self.filecodes{:});

  % create a master list of all filecodes

  if ~exist('data', 'var')
    data = table;
  end

  data.filenames = self.filenames;
  data.filecodes = self.filecodes;

end % function
