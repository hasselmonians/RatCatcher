function batchFunction(index, location, batchname, outfile, test)

  %% Preamble

  if nargin < 4
    test = false;
  end

  % if test is false, do not add to the matlab path
  if ~test
    % NOTE: you will need to change these paths to where RatCatcher and mtools are downloaded on the cluster
    addpath(genpath('/projectnb/hasselmogrp/ahoyland/RatCatcher/'))
    addpath(genpath('/projectnb/hasselmogrp/ahoyland/srinivas.gs_mtools'))
  end

  %% Read data

  [filename, cellnum] = RatCatcher.read(index, location, batchname);

  %% Load data

  val = csvread(filename);

  %% Save the data

  csvwrite(outfile, [val]);

end % function
