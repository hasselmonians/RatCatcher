function batchscriptpath = getBatchScriptPath(self)
  % determine the batch script name

  switch self.mode
  case 'parallel'
      batchscriptpath = which('RatCatcher-generic-script.sh');
  otherwise
      batchscriptpath = which('RatCatcher-generic-script-parallel.sh');
  end

  assert(~isempty(batchscriptpath), 'batch script path not found, is it on the MATLAB path?')

end
