function output = index(self, dataTable)

  % reads from a cell array or table and determines the indices that match
  % filenames from a parsed data description file

  % Arguments:
    % self : the RatCatcher object
      % requires the 'experimenter' and 'alpha' fields to be filled (calls 'parse')
    % dataTable : either a table with a filenames field or a cell array
  % Outputs:
    % output : the indices of dataTable corresponding to the filenames specified by r.parse

  switch class(dataTable)

  % if dataTable is a table, then find the filenames field
  case 'table'
    try
      filenames = dataTable.filenames;
    catch
      disp('[ERROR] I don''t know what to do with this dataTable');
    end

  % if dataTable is a cell, make sure it's n x 1
  case 'cell'
    assert(~isvector(dataTable), 'Cell array must be a vector or scalar')
    if size(dataTable, 1) < size(dataTable, 2)
      dataTable = dataTable';
    end
    filenames = dataTable;
  end

  % fetch the filenames to be indexed
  names   = self.parse;

  % index one-by-one
  output  = NaN(length(names), 1);
  for ii = 1:length(names)
    output(ii) = find(strcmp(filenames, names{ii}));
  end

end % function
