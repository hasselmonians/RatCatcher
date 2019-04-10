function batchfuncname = getBatchFuncName(self)
  % acquires the batch function full path

  batchfuncname = which([protocol '.batchFunction']);
  if numel(batchfuncname) == 0
    batchfuncname = [];
  end

end
