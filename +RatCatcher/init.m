function init(isCluster)

    % sets the matlab path for the RatCatcher package
    % depends on srinivas.gs_mtools package

    if ~exist('isCluster', 'var')
        isCluster = false;
    end

    % e.g. ~/code
    code_dir = pathlib.strip(mfilename('fullpath'), 3);

    if isCluster
        addpath /projectnb/hasselmogrp/ahoyland/scripts
        addpath /projectnb/hasselmogrp/ahoyland/srinivas.gs_mtools
    else
        addpath(code_dir)
        addpath(fullfile(code_dir, 'srinivas.gs_mtools'))
    end

    addpath(fullfile(code_dir, 'RatCatcher'))
    addpath(fullfile(code_dir, 'RatCatcher', 'batchfunctions'))
    addpath(fullfile(code_dir, 'RatCatcher', 'natsort'))
    addpath(fullfile(code_dir, 'RatCatcher', 'scripts'))

end % function
