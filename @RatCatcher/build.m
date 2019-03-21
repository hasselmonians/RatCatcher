function [filepaths] = build(identifiers, filesig, masterpath)

  % constructs a list of filepaths that fit a certain pattern
  % if the directory paths are not absolute, rebase looks within the current working directory
  %
  % filepaths = RatCatcher.rebase(identifiers, filesig)
  %
  % filepaths = RatCatcher.rebase(identifiers, filesig, masterpath)
  %
  % Arguments:
  %   identifiers: a cell array of directory paths in which to search
  %     for example: {'/data/rat1', 'data/rat2'}
  %   filesig: a character vector which indicates which files to find
  %     for example, 'ExperimentID*.csv' finds only .csv files
  %     that begin with 'ExperimentID' in the directories indicated by identifiers
  %     for example, fullfile('**', 'ExperimentID*.csv') finds only .csv files
  %     that begin with 'ExperimentID' in the directory and subdirectories indicated by identifiers
  %   masterpath: optional argument, a character vector of a directory to append to each
  %     identifier
  %     for example: '/projectnb/projectname/experimenter'
  % Outputs:
  %   filepaths: a cell array of absolute filepaths
  %

  if nargin < 3
    masterpath = [];
  end

  filepaths = {};

  for ii = 1:numel(identifiers)

    % prepend the master path if it exists
    if ~isempty(masterpath)
      filepath = fullfile(masterpath, identifiers{ii}, filesig);
    else
      filepath = fullfile(identifiers{ii}, filesig);
    end

    % convert to absolute path
    filepath = rel2abs(filepath);

    % acquire the directory objects
    dirs = dir(filepath);

    % add to filepaths
    for qq = 1:length(dirs)
      filepaths{end+1} = fullfile(dirs(qq).folder, dirs(qq).name);
    end
  end

end % function

function F = rel2abs(F)
  if ~java.io.File(F).isAbsolute
      F = fullfile(pwd,F);
  end
end % function
