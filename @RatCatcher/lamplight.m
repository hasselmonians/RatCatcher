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
		corelib.verb(self.verbose, 'lamplight', ['beginning lamplighting for protocol: ' self.protocol])
		corelib.verb(isempty(self.batchname), 'WARN', 'batchname is empty')

		% set up the filepaths
		options_filename = ['options-' self.batchname '.mat'];
		channel_filename = ['channel_map-' self.batchname '.mat'];
		options_local_filepath = fullfile(self.localpath, options_filename);
		channel_local_filepath = fullfile(self.localpath, channel_filename);

		options_exist = exist(options_local_filepath, 'file');
		channel_exist = exist(channel_local_filepath, 'file');

		if ~options_exist | ~channel_exist
			% instantiate the KiloPlex object
			k = KiloPlex();
			k.options.chanMap = fullfile(self.remotepath, channel_filename);
			% set options according to key-value arguments
			k.options = corelib.parseNameValueArguments(k.options, varargin{:});
			% make directory if needed
			filelib.mkdir(self.localpath)

			if ~options_exist
				% create options file
				options = k.options;
				save(options_local_filepath, 'options');
				corelib.verb(self.verbose, 'lamplight', ['creating options file at ' options_local_filepath])
			end

			if ~channel_exist
				% use options from file if available
				if options_exist
					load(options_local_filepath)
					k.options = options;
				end
				% create channel map file
				k.createChannelMap(channel_local_filepath);
				corelib.verb(self.verbose, 'lamplight', ['creating channel map file at ' channel_local_filepath])
			end
		else
			corelib.verb(self.verbose, 'lamplight', ['options and channel map already exist'])
		end

		filepaths = {options_local_filepath, channel_local_filepath};

	otherwise
		% do nothing
		corelib.verb(self.verbose, 'lamplight', ['no lamplighting indicated for protocol: ' self.protocol])
		filepaths = [];

	end % switch

end % function
