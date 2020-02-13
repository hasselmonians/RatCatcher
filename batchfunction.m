function batchFunction(location, batchname, outfile, test)

    % This is an example batch function for use with non-array jobs.
    % We don't need an array job because the actual computation here is very fast.
    % Therefore, we don't want to request a lot of nodes on the cluster
    % and start up MATLAB hundreds of times.
    % Instead, we can use one node with many cores
    % and perform the computation in parallel that way.

    % We don't want to reload the same data file multiple times,
    % so we find the unique filenames
    % and use a linear indexing trick to iterate in another loop over the filecodes
    % associated with that unique filename.

    % This function relies on the CellSorter protocol
    % (https://github.com/hasselmonians/CellSorter) package
    % and the CMBHOME.Session data format
    % (https://github.com/hasselmonians/CMBHOME).

  if ~test
    addpath(genpath('/projectnb/hasselmogrp/ahoyland/RatCatcher'))
    addpath(genpath('/projectnb/hasselmogrp/ahoyland/srinivas.gs_mtools'))
    addpath(genpath('/projectnb/hasselmogrp/ahoyland/CMBHOME'))
    addpath(genpath('/projectnb/hasselmogrp/ahoyland/CellSorter'))
  end

  %% Load the raw data

  % acquire all filenames and filecodes
  [filenames, filecodes] = RatCatcher.read([], location, batchname);

  % collect unique filenames and a linear index vector map
  % such that all(strcmp(filenames, unique_filenames(filename_index))) == true
  [unique_filenames, ~, filename_index] = unique(filenames);

  %% Perform a parallel for loop over all unique filenames

  parfor index = 1:length(unique_filenames)

    % find the linear indices into 'filenames' and 'filecodes'
    % for all filecodes associated with the unique filename
    these_indices = find(filename_index == index);

    % load the correct data file
    % expect a 1x1 CMBHOME.Session object named 'root'
    this = load(unique_filenames{ii});
    root = this.root;
    this = [];

    %% Sub-loop over all filecodes associated with the unique filename

    for qq = 1:length(these_indices)

      % acquire the filecodes associated with this unique filename one by one
      this_filecode = filecodes(these_indices(qq), :);

      % set up the correct recording from the CMBHOME.Session object
      root.cel = this_filecode;

      %% BEGINNING OF CODE UNIQUE TO THIS ANALYSIS %%

      % You don't have to worry about understanding this part
      % unless you are interested in using the CellSorter protocol.
      % This section should be replaced by your analysis.

      % initialize outputs
      waveform = NaN(50, 4);

      % acquire the waveform, which should be a 50x4 matrix in millivolts
      % the first index is over time steps, the second over channels in the tetrode
      try
        waveform = [root.user_def.waveform(this_filecode(1), :).mean];
      catch
        % acquiring the waveform has failed
        % this happens if the user_def.waveform property is not defined
        % (usually occurs in 'merged' trials)
        % save NaNs instead
        output = [waveform NaN(size(waveform, 1), 1)];
        % save these data as a .csv file
        this_outfile = [outfile '-' num2str(these_indices(qq)) '.csv'];
        writematrix(this_outfile, output);
        % quit early
        break
      end

      % channel with the strongest signal
      channel = findStrongestChannel(waveform);

      % compute the spike width
      % spike width is defined as difference
      % between the first maximum in the signal and the following minimum
      [~, peak_index] = max(waveform(:, channel));
      [~, spike_width] = min(waveform(peak_index:end, channel));
      spike_width = spike_width; % units of time-steps

      % compute the firing rate
      firing_rate = length(CMBHOME.Utils.ContinuizeEpochs(root.cel_ts)) / (root.ts(end) - root.ts(1));

      % create a combined output matrix
      % the first 50x4 block comprises the waveforms
      % the last column is NaN except for the first two elements
      % which are the spike width in ms and the firing rate in Hz
      output = [waveform NaN(size(waveform, 1), 1)];
      output(1, end) = spike_width;
      output(2, end) = firing_rate;
      output(3, end) = channel;

      %% END OF CODE UNIQUE TO THIS ANALYSIS %%

      %% Write output to file

      % save these data as a .csv file
      this_outfile = [outfile '-' num2str(these_indices(qq)) '.csv'];
      writematrix(this_outfile, output);

    end % for

  end % parfor

end % function
