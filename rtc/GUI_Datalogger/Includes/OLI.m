classdef OLI
    properties( Constant = true )
	ONLINE_GETERROR		= 0
	ONLINE_GETENABLE	= 1	% 1 if specified channel is enabled, 0 if not
	ONLINE_GETRATE		= 2	% number of samples per second on the specified channel
	ONLINE_GETSAMPLES	= 3	% the number of unread samples on the specified channel
	ONLINE_GETVALUE		= 4	% the (current value + 4000) on the specified channel
	ONLINE_START		= 5	% start or re-start data transfer
	ONLINE_STOP			= 6	% stop data transfer
    
	ONLINE_OK			= 0
	ONLINE_COMMSFAIL	= -3
	ONLINE_OVERRUN		= -4
    end
end
