function data = stitch(self, data)

  % stitches parsed filenames and cell numbers into datasets

  % Arguments:
    % experimenter: expects either 'Caitlin' or 'Holger'
    % alpha: the alphanumeric identifier for the experimentalist's data
    % for experimenter = 'Caitlin', this should be an ID from cluster_info.mat
    % e.g. 'A' or 'B', etc.
    % data: m x n table, the data table (probably from RatCatcher.gather)
  % Outputs:
    % data: m x n+2 table, the data table

  [filenames, filecodes] = self.parse();
  data2 = table(filenames, filecodes);
  data = [data data2];

end % function
