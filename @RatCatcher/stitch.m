function new_table = stitch(self, old_table)

  % stitches parsed filenames and cell numbers into datasets in the form of a table
  % if no dataset is specified, it creates a new table

  % Arguments:
    % self: an object of the RatCatcher class
    %   the `filenames` and `filecodes` properties need to be well-formed
    %   this is checked at the beginning of this function by running `validate()`
    % old_table: m x n table, the data table (probably from RatCatcher.gather)
    %   this is an optional argument
  % Outputs:
    % new_table: m x n+2 table, the data table with the filenames and filecodes added
    %   if concatenating the two tables fails, only the m x 2 new table is returned

  % check to make sure that your object is up-to-date
  self = self.validate;

  % create a master list of all filenames by compressing the filenames cell structure (if any)
  % expect an n x 1 cell array of character vectors
  filenames = cat(1, self.filenames{:});

  % create a master list of all filecodes the same way
  % expect an n x m numerical matrix
  filecodes = cat(1, self.filecodes{:});

  % produce a new data table containing the filenames and filecodes
  new_table = table;
  new_table.filenames = filenames;
  new_table.filecodes = filecodes;

  if ~exist('old_table', 'var')
    return
  end

  % attempt to add the new_table to the old_table
  try
    new_table = [old_table new_table];
  catch
    core.verb(self.verbose, 'stitch', 'Couldn''t stitch tables together, returning the new table')
  end

end % function
