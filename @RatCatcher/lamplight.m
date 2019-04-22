function filepaths = lamplight(self, varargin)

	% performs bookkeeping routines based on the protocol
	% the protocol is read from the RatCatcher object
	% self.batchname is used to check for files with the correct name
	% variable input arguments are for use before batchify by the user
	% they are specific to each protocol
	% Outputs:
	% 	filepaths: a cell array of character vectors
	% 		which contains a list of filepaths of configuration files
	% 		generated automatically by lamplight()
	% 		this list is useful as a set of "do not erase" files

	switch self.protocol

	case 'KiloPlex'
		% save the KiloPlex.options data structure as a .mat file in localpath
		% varargin allows modification of the options before saving

		% set up the filepaths
		options_filename = ['options-' self.batchname '.mat'];
		channel_filename = ['channel_map-' self.batchname '.mat'];
		options_filepath = fullfile(self.localpath, options_filename);
		channel_filepath = fullfile(self.localpath, channel_filename);

		options_exist = exist(options_filepath, 'file');
		channel_exist = exist(channel_filepath, 'file');

		if ~options_exist | ~channel_exist
			% instantiate the KiloPlex object
			k = KiloPlex();
			k.options.chanMap = channel_filepath;
			% set options according to key-value arguments
			k.options = validateArgs(k.options, varargin{:});
			% make directory if needed
			filelib.mkdir(self.localpath)

			if ~options_exist
				% create options file
				options = k.options;
				save(options_filepath, 'options');
			end

			if ~channel_exist
				% create channel map file
				k.createChannelMap(channel_filepath);
			end
		end

		filepaths = {options_filepath, channel_filepath};

	otherwise
		% do nothing

	end % switch

end % function
