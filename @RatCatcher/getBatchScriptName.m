function batchname = getBatchScriptName(self)
  % comes up with a verbose name that unambiguously identifies any batchname file

  expID     = self.expID;
  protocol  = self.protocol;

  if isempty(expID)
    batchname = ['test' '-' protocol];
    return
  end

  if iscell(expID)
    expID  = expID';
    batchname = expID{1};

    for ii = 2:numel(expID)
      batchname = [batchname '-' expID{ii}];
    end

    batchname = [batchname '-' protocol];
  else
    batchname = [expID '-' protocol];
  end

end % function
