classdef StimServer < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        server
    end
    
    methods
        
    function obj = openServer(obj)              
        try
            if Devices.onLuisPc	 
				clc;
				obj.server= udpport("LocalPort", Devices.luisPcPort, "EnablePortSharing", true);
				obj.server.EnableBroadcast = true;
				
                disp('Opened Stimulus Server (upd)')                
				write2Commander(obj, "HELLO")
            else
               error('Unkown Machines; cannot set up comminication') 
            end
            % fopen(obj.server);
        catch ME
            % instrreset;  
            % disp('Error but safely closed')
            rethrow(ME)
        end
    end         
        
        function write2Commander(obj, message)
            if strcmp(obj.server.Status, 'open')    
				
				% write(obj.server, message, "string", "255.255.255.255", Devices.luisPcPort);
				write(obj.server, message, "string", "255.255.255.255", Devices.luisPcPort);
				flush(obj.server,'input')
                fprintf('\nSent: ''%s''\n', message);

            elseif strcmp(obj.server.Status, 'close')                    
                disp('server cannot write bc not open')
            end
        end
        
        function msg = readMessageIfAvailable(obj)
            if obj.server.BytesAvailable
				disp("Num Bytes before")
				obj.server.NumBytesAvailable
				msg = read(obj.server, obj.server.NumBytesAvailable,"string");
				disp("Num Bytes after")
				obj.server.NumBytesAvailable

            else
                msg = '';
            end
        end
        
        function obj = closeServer(obj)
            % if strcmp(obj.server.Status, 'open') 
            %     fclose(obj.server);
            %     delete(obj.server);
            % end        
        end
        
        
    end
    
end

