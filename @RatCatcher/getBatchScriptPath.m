function batchscriptpath = getBatchScriptPath(self)
  % determine the batch script name

  switch self.mode
  case 'parallel'
      batchscriptpath = which('RatCatcher-generic-script-parallel.sh');
  case 'array'
      batchscriptpath = which('RatCatcher-generic-script-array.sh');
  otherwise
      batchscriptpath = which('RatCatcher-generic-script.sh');
  end

  assert(~isempty(batchscriptpath), 'batch script path not found, is it on the MATLAB path?')

end
