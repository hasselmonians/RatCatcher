function clean(self, keepthis)
  % removes old files created by RatCatcher
  % requires self.localpath and self.batchname to be set
  % removes all files in self.localpath which contain self.batchnmame somewhere in the filename
  % does **not** remove files within the |keepthis| cell array of character vectors
  % Arguments:
  %   self: the RatCatcher object
  %   keepthis: a cell array of character vectors of filepaths of file

  warning off all

  % make a list of all files in the localpath directory containing the batchname in the filename
  dd = dir(fullfile(self.localpath, ['*', self.batchname, '*']));
  files2delete = {dd.name};

  % remove the files not flagged for keeping
  count = 0;
  for ii = 1:length(files2delete)
    if ~any(keepthis, files2delete{ii})
      delete(files2delete{ii})
      count = count + 1;
    end
  end

  if self.verbose == true
    disp(['[INFO] all old files removed (', num2str(count), ' files)'])
  end

  warning on all
