classdef StimCommander < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        commander
        madeContact 
    end
    
    methods
        

    function msg = openCommander(obj)
		msg = obj.openTcpipOnNewMatlab;

    end         

    
    function msg = openTcpipOnNewMatlab(obj)
        !matlab -r prg=StimProgram &
        tStart = tic;
        while toc(tStart) < 30 % wait 30 seconds for new matlab to open and start program
            try
				obj.commander= udpport("LocalPort", Devices.luisPcPort, "EnablePortSharing", true);
				obj.commander.EnableBroadcast = true;
				% fopen(obj.commander);
            catch ME
                fprintf('\n***SEE ERROR BELOW***\n')
                disp(ME)
                fprintf('\n***SEE ERROR ABOVE***\n')                    
            end  

            if strcmp(obj.commander.Status, 'open')
                msg = 'SUCCESS: SESSION 1 COMMANDER OPENED SESSION 2 STIM SERVER';
                obj.madeContact = true;
                break;
            else
                msg = 'FAILURE: SESSION 1 COMMANDER COULD NOT OPEN SESSION 2 STIM SERVER';
                disp(msg);
                obj.madeContact = false;                
                disp('Will Try Again');
            end                
            pause(1.5)
            fprintf('\n%s\n', msg)
        end
    end


    function [info, failed ] = Write(obj, message)
        if obj.madeContact
			write(obj.commander, message, "string", "255.255.255.255", Devices.luisPcPort);
			flush(obj.commander,'input')
            info = sprintf('Sent *%s* to viewer', message);
            failed = false;
        else 
            info = sprintf('Failed to write *%s* to viewer', message);
            failed = true;                
        end
        disp(info)
    end

    function [msg, info, failed]= waitForMessage(obj, timeOut)  
        if ~isempty(obj.commander) && isvalid(obj.commander) && strcmp(obj.commander.Status, 'open')
            tStart = tic;
            while toc(tStart) < timeOut
                msg = obj.readMessageIfAvailable;                
                if ~isempty(msg) 
                    failed = false;
                    info = sprintf('Message *%s* received from viewer', msg);
                    break;
                end              
            end
            if isempty(msg)                     
                failed = true;
                info = sprintf('NO MESSAGE RECEIVED from viewer');
            end        
        else
            msg = '';
            failed = true;
            info = sprintf('No Message Received (Not in contact w/ viewer');
        end
        
        
    end

    function msg = readMessageIfAvailable(obj)        
        if ~isempty(obj.commander) && obj.commander.BytesAvailable
			% msg = read(obj.commander, obj.commander.NumBytesAvailable, "string");
			msg = read(obj.commander,obj.commander.NumBytesAvailable,"string");

        else
            msg = '';
        end
    end

    function obj = closeCommander(obj)
        if ~isempty(obj.commander) && strcmp(obj.commander.Status, 'open')
            if obj.madeContact
                obj.Write(StimMessages.shutDown)
            end
            fclose(obj.commander);
            delete(obj.commander);
        end  
    end

        
    end
    
end

