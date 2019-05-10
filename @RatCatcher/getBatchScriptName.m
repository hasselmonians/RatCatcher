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

  if iscell(self.expID) & size(self.expID, 1) > 1
    batchname = cell(size(self.expID, 1), 1);

    for ii = 1:size(self.expID, 1)
      batchname{ii} = self.expID{ii, 1};
      for qq = 2:size(self.expID, 2)
        batchname{ii} = [batchname{ii} '-' self.expID{ii, qq}];
      end
      batchname{ii} = [batchname{ii} '-' self.protocol];
    end

  else
    batchname = [self.expID '-' self.protocol];
  end

end % function
