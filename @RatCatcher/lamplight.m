function lamplight(self, varargin)

	% performs bookkeeping routines based on the protocol

	switch self.protocol

	case 'KiloPlex'
		% save the KiloPlex.options data structure as a .mat file in localPath
		% varargin allows modification of the options before saving

		k = KiloPlex();

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

		k.publish(self.localPath);

	otherwise
		disp('[ERROR] I don''t know what to do')
	end % switch

end % function
