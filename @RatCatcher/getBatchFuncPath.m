function batchfuncpath = getBatchFuncPath(self)
  % acquires the batch function full path

  if self.parallel
    batchfuncpath = which([self.protocol '.batchFunction_parallel']);
  else
    batchfuncpath = which([self.protocol '.batchFunction']);
  end

  if numel(batchfuncpath) == 0
    batchfuncpath = [];
    corelib.verb(self.verbose, 'getBatchFuncPath', 'no batch function found at '' batchfuncpath ''')
  end

end
