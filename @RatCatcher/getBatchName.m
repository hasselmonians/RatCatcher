function output = getBatchName(expID, protocol)
  % comes up with a verbose name that unambiguously identifies any output file

  expID  = expID';
  output = expID{1};

  for ii = 2:numel(expID)
    output = [output '-' expID{ii}];
  end

  output = [output '-' protocol]

end % function
