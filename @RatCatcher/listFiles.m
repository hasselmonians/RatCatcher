function [filepaths] = listFiles(identifiers, filesig, masterpath)

  % constructs a list of filepaths that fit a certain pattern
  % if the directory paths are not absolute, rebase looks within the current working directory
  %
  % filepaths = RatCatcher.rebase(identifiers, filesig)
  %
  % filepaths = RatCatcher.rebase(identifiers, filesig, masterpath)
  %
  % Arguments:
  %   identifiers: a cell array of directory paths in which to search
  %     follows the same conventions as the RatCatcher property expID
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
  % See also: RatCatcher, RatCatcher.parse, RatCatcher.batchify

  %% Parse inputs

  % set defaults
  if nargin < 3
    masterpath = [];
  end

  % parse the identifiers argument
  if iscell(identifiers)
    if size(identifiers, 1) ~= 1
      % identifiers has multiple sets (i.e. rows)
      % construct the file list by reading each row
      filepaths = listFiles_core(identifiers(1,:), filesig, masterpath);
      for ii = 2:size(expID, 1)
        filepaths0  = listFiles_core(identifiers(ii,:), filesig, masterpath);
        filepaths   = [filenames; filenames0];
      end
    else
      % identifiers is a row vector cell array or a scalar cell array
      filepaths = listFiles_core(identifiers(1, :), filesig, masterpath);
    end
  else
    % identifiers is a character vector
    filepaths = listFiles_core({identifiers}, filesig, masterpath);
  end
end
% end function

function filepaths = listFiles_core(identifiers, filesig, masterpath)

  % builds the filepath list by finding files that match filesig]
  % in the directory specified by identifiers and masterpath

  filepaths = {};

  for ii = 1:numel(identifiers)
    % prepend the master path if it exists
    filepath = fullfile(masterpath, identifiers{ii,:}, filesig);

    % convert to absolute path
    filepath = rel2abs(filepath);

    % acquire the directory objects
    dirs = dir(filepath, filesig);

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
