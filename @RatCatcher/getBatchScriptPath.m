function batchscriptpath = getBatchScriptPath(self)
  % determine the batch script name

  if self.parallel == false
    batchscriptpath = which('RatCatcher-generic-script.sh');
  else
    batchscriptpath = which('RatCatcher-generic-script-parallel.sh');
  end

  assert(~isempty(batchscriptpath), 'batch script path not found, is it on the MATLAB path?')

end
