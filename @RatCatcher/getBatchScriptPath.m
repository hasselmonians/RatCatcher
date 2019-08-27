function batchscriptpath = getBatchScriptPath(self)
  % determine the batch script name

    batchscriptpath = which('RatCatcher-generic-script.sh');
    assert(~isempty(batchscriptpath), 'batch script path not found, is it on the MATLAB path?')

end
