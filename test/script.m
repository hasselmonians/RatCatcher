% NOTE: you will need to change the following path to where you installed RatCatcher locally
RatCatcher_path = '/home/alec/code/RatCatcher';

r = RatCatcher;

r.expID       = 'test';

% NOTE: you will need to change the following paths to make sense for you
r.remotepath  = '/projectnb/hasselmogrp/ahoyland/RatCatcher/cluster';

% I have used sshfs to mount the cluster locally
% If I didn't do this, I would have to specify a local path and then manually copy the files over.
r.localpath   = '/mnt/hasselmogrp/ahoyland/RatCatcher/cluster';

r.protocol    = 'Test';
r.project     = 'hasselmogrp';

% Manually add the test data
r.filenames   = {fullfile(RatCatcher_path, 'test/data/datafile_1.csv'); ...
                fullfile(RatCatcher_path, 'test/data/datafile_2.csv')};

r = r.batchify;
