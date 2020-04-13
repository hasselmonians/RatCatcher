%% Test Script

% This script contains a demo for how to use RatCatcher.
% It will run a trivial MATLAB function on the cluster,
% that copies a matrix.

% find the path to the RatCatcher directory
RatCatcher_path = pathlib.strip(mfilename('fullpath'), 2);

%% Create the RatCatcher object

r = RatCatcher;

% identify the experimenter as "test"
r.expID       = 'test';

% NOTE: you will need to change the following paths to make sense for you
% this should be the directory path to where you want to store files on the cluster
r.remotepath  = '/projectnb/hasselmogrp/ahoyland/RatCatcher/cluster';

% NOTE:
% I have used sshfs to mount the cluster locally, so that I can treat the cluster as part of my local filesystem.
% If I didn't do this, I would have to specify a path accessible by my local computer,
% and then manually copy the files over.
% If this directory doesn't exist, you will have to create it.
r.localpath   = '/mnt/hasselmogrp/ahoyland/RatCatcher/cluster';

r.protocol    = 'Test';
r.project     = 'hasselmogrp';

%% Manually add the test data

% local, relative paths to the raw data files in the RatCatcher directory
data_paths    = {'datafile_1.csv', 'datafile_2.csv'};

% local paths to the raw data files on the cluster
r.filenames   = strcat(r.remotepath, filesep, data_paths);

% copy the raw data files to the cluster location
% in general, you won't need to do this
% this is necessary here because of how contrived this example is
copyfile(fullfile(RatCatcher_path, 'test', 'data', data_paths{1}), r.localpath);
copyfile(fullfile(RatCatcher_path, 'test', 'data', data_paths{2}), r.localpath);

%% Create the batch files on the cluster

r = r.batchify();

%% Run the analysis on the cluster

return
% cd /projectnb/hasselmogrp/ahoyland/RatCatcher/cluster
% qsub batchscript-test-Test.sh

%% Gather the data locally

data_table = r.gather();
