function batchfuncpath = getBatchFuncPath(self)
  % acquires the batch function full path

  batchfuncpath = which([protocol '.batchFunction']);
  if numel(batchfuncpath) == 0
    batchfuncpath = [];
  end

end
