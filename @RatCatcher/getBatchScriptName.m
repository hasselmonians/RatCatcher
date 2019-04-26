function batchname = getBatchScriptName(self)
  % comes up with a verbose name that unambiguously identifies any batchname file
  % the basic form is self.expID + self.protocol
  % where batchname is a cell array of size n x 1
  % where n is the number of rows in self.

  if isempty(self.expID)
    batchname = ['test' '-' self.protocol];
    return
  end

  if iscell(self.expID)
    batchname = cell(size(self.expID, 1), 1);

    for ii = 1:size(self.expID, 1)
      batchname{ii} = self.expID{ii, 1};
      for qq = 1:size(self.expID, 2)
        batchname{ii} = [batchname{ii} '-' self.expID{ii, qq}];
      end
      batchname{ii} = [batchname{ii} '-' self.protocol];
    end
    batchname = [batchname '-' self.protocol];

  else
    batchname = [self.expID '-' self.protocol];
  end

end % function
