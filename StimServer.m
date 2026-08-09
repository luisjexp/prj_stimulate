classdef StimServer < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        server
    end
    
    methods
        
    function obj = openServer(obj)              
        delete(instrfind('tag', Devices.stimPrgNameTag));
        try
            if Devices.onLuisPc	 
                obj.server = udp(Devices.luisMacIp,Devices.luisMacPort,'LocalPort', Devices.luisPcPort, 'tag', Devices.stimPrgNameTag);              
                disp('Opened Stimulus Server (upd)')                
            elseif Devices.onTrachPc
                obj.server = tcpip('0.0.0.0', Devices.trachPcPort, 'NetworkRole', 'server');
                disp('Opened Stimulus Server (tcpip)')
            else
               error('Unkown Machines; cannot set up comminication') 
            end
            fopen(obj.server);
        catch ME
            instrreset;  
            disp('Error but safely closed')
            rethrow(ME)
        end
    end         
        
        function write2Commander(obj, message)
            if strcmp(obj.server.Status, 'open')                
                fprintf(obj.server, message);
                fprintf('\nSent: ''%s''\n', message);

            elseif strcmp(obj.server.Status, 'close')                    
                disp('server cannot write bc not open')
            end
        end
        
        function msg = readMessageIfAvailable(obj)
            if obj.server.BytesAvailable
                msg = fscanf(obj.server, '%s');
            else
                msg = '';
            end
        end
        
        function obj = closeServer(obj)
            if strcmp(obj.server.Status, 'open') 
                fclose(obj.server);
                delete(obj.server);
            end        
        end
        
        
    end
    
end

