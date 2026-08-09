classdef StimCommander < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        commander
        madeContact 
    end
    
    methods
        

    function msg = openCommander(obj)
        if Devices.onLuisMac 
            msg = obj.attemptUdpConnection;
        elseif Devices.onTrachPc
            msg = obj.openTcpipOnNewMatlab;
        else
           error('Unkown communication setup') 
        end
    end         

    function msg = attemptUdpConnection(obj)
        delete(instrfind('tag', Devices.stimCmdNameTag));
        obj.commander = udp(Devices.luisPcIp, Devices.luisPcPort,'LocalPort',Devices.luisMacPort, 'tag', Devices.stimCmdNameTag);
        fopen(obj.commander);
        try
        obj.write(StimMessages.get_lifeTime);
        catch ME
            disp(ME)
        end
        obj.madeContact = ~isempty(obj.waitForMessage(3));
        
        if obj.madeContact
            msg = 'STIM CONTACT SUCCESSFULL (via UDP) Stimulus Program Ready'; 
        else
            
            msg = 'STIM CONTACT FAILED: Stim Program UDP could not be opened';                
        end
        fprintf('\n%s\n', msg)        
    end
    
    function msg = openTcpipOnNewMatlab(obj)
        !matlab -r prg=StimProgram &
        tStart = tic;
        while toc(tStart) < 30 % wait 30 seconds for new matlab to open and start program
            try
                delete(instrfind('tag', Devices.stimCmdNameTag));
                obj.commander = tcpip('localhost', Devices.trachPcPort, 'NetworkRole', 'client','tag', Devices.stimCmdNameTag);                    
                fopen(obj.commander);
            catch ME
                fprintf('\n***SEE ERROR BELOW***\n')
                disp(ME)
                fprintf('\n***SEE ERROR ABOVE***\n')                    
            end  

            if strcmp(obj.commander.Status, 'open')
                msg = 'STIM CONTACT SUCCESS (via TCP/IP) Stimulus Program Ready';
                obj.madeContact = true;
                break;
            else
                msg = 'STIM CONTACT FAILED: Stim Program TCP/IP could not be opened';
                disp(msg);
                obj.madeContact = false;                
                disp('Will Try Again');
            end                
            pause(1.5)
            fprintf('\n%s\n', msg)
        end
    end


    function [info, failed ] = write(obj, message)
        if obj.madeContact
            fprintf(obj.commander, message);
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
            msg = fscanf(obj.commander, '%s');
        else
            msg = '';
        end
    end

    function obj = closeCommander(obj)
        if ~isempty(obj.commander) && strcmp(obj.commander.Status, 'open')
            if obj.madeContact
                obj.write(StimMessages.shutDown)
            end
            fclose(obj.commander);
            delete(obj.commander);
        end  
    end

        
    end
    
end

