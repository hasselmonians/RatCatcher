function batchname = getBatchScriptName(self)
  % comes up with a verbose name that unambiguously identifies any batchname file
  % the basic form is self.expID + self.protocol
  % where batchname is a cell array of size n x 1
  % where n is the number of rows in self.
  %
  % batchname = r.getBatchScriptName()
  %
  % Example:
  %
  %   >> r.getBatchScriptName
  %
  % ans =
  %
  %   5×1 cell array
  %
  %     {'Caitlin-A-BandwidthEstimator'}
  %     {'Caitlin-B-BandwidthEstimator'}
  %     {'Caitlin-C-BandwidthEstimator'}
  %     {'Caitlin-D-BandwidthEstimator'}
  %     {'Caitlin-E-BandwidthEstimator'}
  %
  %
  % See also RatCatcher, RatCatcher.getBatchScriptPath

  if isempty(self.expID)
    batchname = ['test' '-' self.protocol];
    return
  end

  if iscell(self.expID)
    % expID is a cell array
    if size(self.expID, 1) > 1
      % expID is a cell array with multiple rows
      % the batch name is a cell of the same length
      batchname = cell(size(self.expID, 1), 1);
      % iterate through expID row-wise to generate that batch name
      for ii = 1:size(self.expID, 1)
        batchname{ii} = self.expID{ii, 1};
        for qq = 2:size(self.expID, 2)
          batchname{ii} = [batchname{ii} '-' self.expID{ii, qq}];
        end
        batchname{ii} = [batchname{ii} '-' self.protocol];
      end  
    else
      % expID is a single row cell array
      % the batch name is a character vector
      batchname = [strjoin(self.expID, '-') '-' self.protocol];
    end
  else
    % expID is a character vector
    % the batch name is a character vector
    batchname = [self.expID '-' self.protocol];
  end

end % function
