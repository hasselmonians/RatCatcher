function output = index(self, dataTable, cellnums)

  % reads from a cell array or table and determines the indices that match
  % filenames from a parsed data description file

  % Arguments:
    % self : the RatCatcher object
      % requires the 'experimenter' and 'alpha' fields to be filled (calls 'parse')
    % dataTable : either a table or a cell array
      % if dataTable is a table, then it must have 'filenames' and 'cellnums' as fields
      % if datatable is a cell array, it can be n x 1 or n x 2, where the second column
      % should be the cellnums, otherwise, the cellnums argument is needed
    % cellnums : if dataTable is a scalar or vector cell array, then cellnums contains the cell-experiment identifier
      % this is a 1x2 vector for each filename to be indexed
      % so for 10 names, cellnums should be 10x2
  % Outputs:
    % output : the indices of dataTable corresponding to the filenames specified by r.parse

  switch class(dataTable)

  % if dataTable is a table, then find the filenames field
  case 'table'
    try
      filenames   = dataTable.filenames;
      cellnums    = dataTable.cellnums;
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
    % if dataTable is an n x 2 cell array, build the n x 2 matrix of cellnums
    if nargin < 3 && size(dataTable, 2) == 2
      cellnums = zeros(length(dataTable), 2);
      for ii = 1:length(dataTable)
        cellnums(ii, :) = dataTable{ii, 2};
      end
    else
      disp('[ERROR] Cell array contains insufficient information, "cellnums" required')
      output = [];
      return
    end
  end

  % fetch the filenames to be indexed
  [names, nums] = self.parse;
  keyboard
  % index one-by-one
  output  = NaN(length(names), 1);
  for ii = 1:length(names)
    output(ii) = find(strcmp(filenames, names{ii}) & all((cellnums == nums(ii, :))')')
  end

end % function
