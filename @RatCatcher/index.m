function output = index(self, dataTable)

  % reads from a cell array or table and determines the indices that match
  % filenames from a parsed data description file

  % Arguments:
    % self : the RatCatcher object
      % requires the 'experimenter' and 'alpha' fields to be filled (calls 'parse')
    % dataTable : either a table or a cell array
      % if dataTable is a table, then it must have 'filenames' and 'filecodes' as fields
      % if datatable is a cell array, it can be n x 1 or n x 2, where the second column
      % should be the filecodes, otherwise, the filecodes argument is needed
    % filecodes: if dataTable is a scalar or vector cell array, then filecodes contains the cell-experiment identifier
      % this is a 1x2 vector for each filename to be indexed
      % so for 10 names, filecodes should be 10x2
  % Outputs:
    % output : the indices of dataTable corresponding to the filenames specified by r.parse

  switch class(dataTable)

  % if dataTable is a table, then find the filenames field
  case 'table'
    try
      filenames   = dataTable.filenames;
      filecodes    = dataTable.filecodes;
    catch
      disp('[ERROR] I don''t know what to do with this dataTable');
      output = [];
      return
    end

  % if dataTable is a cell, make sure it's n x 1
  case 'cell'
    assert(~isvector(dataTable), 'Cell array must be a vector or scalar')
    % if dataTable is a wide cell array, make it tall instead
    if size(dataTable, 1) < size(dataTable, 2)
      dataTable = dataTable';
    end
    % if dataTable is an n x 2 cell array, build the n x 2 matrix of filecodes
    if nargin < 3 && size(dataTable, 2) == 2
      filecodes = zeros(length(dataTable), 2);
      for ii = 1:length(dataTable)
        filecodes(ii, :) = dataTable{ii, 2};
      end
    else
      disp('[ERROR] Cell array contains insufficient information, "filecodes" required')
      output = [];
      return
    end
  end

  % fetch the filenames to be indexed
  [names, nums] = self.parse;

  % index one-by-one
  output  = NaN(length(names), 1);
  for ii = 1:length(names)
    output(ii) = find(strcmp(filenames, names{ii}) & all((filecodes == nums(ii, :))')');
  end

end % function
