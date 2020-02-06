% NOTE: you will need to change the following path to where you installed RatCatcher locally
RatCatcher_path = '/home/ahoyland/code/RatCatcher';

r = RatCatcher;

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

% Manually add the test data
r.filenames   = {fullfile(RatCatcher_path, 'test/data/datafile_1.csv'); ...
                fullfile(RatCatcher_path, 'test/data/datafile_2.csv')};

r = r.batchify;
