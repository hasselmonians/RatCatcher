function batchfuncpath = getBatchFuncPath(self)
  % acquires the batch function full path

  switch self.mode
  case 'parallel'
      batchfuncpath = which([self.protocol '.batchFunction_parallel']);
  otherwise
      batchfuncpath = which([self.protocol '.batchFunction']);
  end

  if numel(batchfuncpath) == 0
    batchfuncpath = [];
    corelib.verb(self.verbose, 'RatCatcher::getBatchFuncPath', ['no batch function found at ''' batchfuncpath ''''])
  else
    corelib.verb(self.verbose, 'RatCatcher::getBatchFuncPath', ['batch function found at ''' batchfuncpath ''''])
  end

end
