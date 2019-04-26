function clean(self, keepthis)
  % removes old files created by RatCatcher
  % requires self.localpath and self.batchname to be set
  % removes all files in self.localpath which contain self.batchnmame somewhere in the filename
  % does **not** remove files within the |keepthis| cell array of character vectors
  % Arguments:
  %   self: the RatCatcher object
  %   keepthis: a cell array of character vectors of filepaths of file

  warning off all

  % if self.batchname is a cell array, run recursively for each contained character vector
  count = 0;
  if iscell(self.batchname)
    for ii = 1:length(self.batchname)
      count = count + clean_core(self, self.batchname{ii}, keepthis);
    end
  else
    count = clean_core(self, self.batchname, keepthis);
  end

  corelib.verb(self.verbose, 'INFO', ['all old files removed (', num2str(count), ' files)'])

  warning on all

end % function

function count = clean_core(self, this_batchname, keepthis)
  % make a list of all files in the localpath directory containing the batchname in the filename
  dd = dir(fullfile(self.localpath, ['*', this_batchname, '*']));
  files2delete = {dd.name};

  % remove the files not flagged for keeping
  count = 0;
  for ii = 1:length(files2delete)
    if ~any(strcmp(keepthis, files2delete{ii}))
      delete(files2delete{ii})
      count = count + 1;
    end
  end
end % function
