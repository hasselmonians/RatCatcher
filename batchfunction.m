function batchFunction(location, batchname, outfile, test)

    % This is an example batch function for use with non-array jobs.
    % We don't need an array job because the actual computation here is very fast.
    % Therefore, we don't want to request a lot of nodes on the cluster
    % and start up MATLAB hundreds of times.
    % Instead, we can use one node with many cores
    % and perform the computation in parallel that way.

    % This function relies on the CellSorter
    % (https://github.com/hasselmonians/CellSorter) package
    % and the CMBHOME.Session data format
    % (https://github.com/hasselmonians/CMBHOME).

  if ~test
    addpath(genpath('/projectnb/hasselmogrp/ahoyland/RatCatcher'))
    addpath(genpath('/projectnb/hasselmogrp/ahoyland/srinivas.gs_mtools'))
    addpath(genpath('/projectnb/hasselmogrp/ahoyland/CMBHOME'))
    addpath(genpath('/projectnb/hasselmogrp/ahoyland/CellSorter'))
  end

  nFiles = 100;

  %% Perform a parallel for loop over all files

  parfor index = 1:nFiles

      % acquire the filename and filecode
      % the filecode should be the "cell number" as a 1x2 vector
      [filename, filecode] = RatCatcher.read(index, location, batchname);

      % load the data
      % expect a 1x1 CMBHOME.Session object named "root"
      load(filename);
      root.cel = filecode;

      % initialize outputs
      waveform = NaN(50, 4);

      % acquire the waveform, which should be a 50x4 matrix in millivolts
      % the first index is over time steps, the second over channels in the tetrode
      try
        waveform = [root.user_def.waveform(filecode(1), :).mean];
      catch
        % acquiring the waveform has failed
        % save NaNs instead
        output = [waveform NaN(size(waveform, 1), 1)];
        % save these data as a .csv file
        csvwrite([outfile '-' num2str(index) '.csv'], output);
        return
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

      % save these data as a .csv file
      csvwrite([outfile '-' num2str(index) '.csv'], output);
  end % parfor

end % function
