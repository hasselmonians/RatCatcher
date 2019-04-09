function lamplight(self, batchname, varargin)

	% performs bookkeeping routines based on the protocol
	% the protocol is read from the RatCatcher object
	% the batchname is used to check for files with the correct name
	% variable input arguments are for use before batchify by the user
	% they are specific to each protocol

	switch self.protocol

	case 'KiloPlex'
		% save the KiloPlex.options data structure as a .mat file in localPath
		% varargin allows modification of the options before saving

		% check to see if options file already exists
		if ~exist(fullfile(self.localPath, batchname, 'options.mat'), 'file')
			% instantiate object with default properties
			k = KiloPlex();
			% validate arguments
			if mathlib.iseven(length(varargin))
				for ii = 1:2:length(varargin)-1
					temp = varargin{ii};
					if ischar(temp)
						if ~any(find(strcmp(temp,fieldnames(k.options))))
							disp(['Unknown option: ' temp])
							disp('The allowed options are:')
							disp(fieldnames(k.options))
							error('UNKNOWN OPTION')
						else
							k.options.(temp) = varargin{ii+1};
						end
					end
				end
			else
				error('Inputs need to be name value pairs')
			end
			% save the options.mat file
			location = fullfile(self.localPath, batchname, 'options.mat');
			k.publish(location);
			disp(['[INFO] options file saved at: ' location])
	else
		disp('[INFO] options file already exists for this batch name')
	end

	otherwise
		% do nothing

	end % switch

end % function
