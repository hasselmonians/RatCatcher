function output = getBatchName(expID, protocol)
  % comes up with a verbose name that unambiguously identifies any output file

  if isempty(expID)
    output = protocol;
    return
  end

  if iscell(expID)
    expID  = expID';
    output = expID{1};

    for ii = 2:numel(expID)
      output = [output '-' expID{ii}];
    end

    output = [output '-' protocol];
  else
    output = expID;
  end

end % function
