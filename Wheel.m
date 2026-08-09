classdef Wheel < handle 
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Mod 
        connectionStatus 
        previousPosition
        currentPosition
        turnSpeed
        turnDirection
    end
    
    methods 
        function msg = callWheel(obj)  
            tStart = tic;      
            while toc(tStart) < 30 && Devices.onTrachPc          
                try
                    delete(instrfind('tag', Devices.wheelNameTag));
                    pause(.25);
                    obj.Mod = RotaryEncoderModule(Devices.wheelPort); 
                    fopen(obj.Mod);               
                catch ME
                    disp(ME)
                end
                
                if ~isempty(obj.Mod) % if not empty the Module opened
                    msg = 'Wheel Connected :)';
                    obj.connectionStatus = 'Open'; 
                    pause(1);
                    obj.currentPosition = 0;
                    break;
                else
                   obj.connectionStatus = 'Closed';                                       
                   msg = 'Wheel Connection Failed';
                   fprintf('\n%s; will try again...\n', msg);
                end    
                pause(1)
            end
            
            if ~Devices.onTrachPc
                obj.connectionStatus = 'Closed';                                                     
                msg = 'DID NOT ATTEMPT CALL: Wheel not expected on this device. Use [a]&[d] keys to mimic wheel';
                obj.currentPosition = 0;           % zero the encoder

            end
            fprintf('\t%s\n', msg) ;
        end
      
        
        function posDeg = readWheelPosition(obj) % reads and updates the current speed & direction of the wheel turn
            if strcmp(obj.connectionStatus, 'Open')
                posDeg   = round(obj.Mod.currentPosition);    
            else
                posDeg   = obj.currentPosition;
            end
            
            cmd = readKey;
            if strcmp(cmd, 'a')
                  posDeg = obj.currentPosition - 5;
                  if posDeg < -180; posDeg = 180; end
                  
            elseif strcmp(cmd, 'd')
                  posDeg = obj.currentPosition + 5;
                  if posDeg > 180; posDeg = -180; end
            end
            
            obj.previousPosition    = obj.currentPosition;
            obj.currentPosition     = posDeg;
        end
        
        function bool = didTurn(obj)
            if obj.currentPosition ~= obj.previousPosition
                bool = true;
            else
                bool = false;
            end
        end
        
        function zero(obj)
            if strcmp(obj.connectionStatus, 'Open')
                obj.Mod.zeroPosition;
            end
                obj.currentPosition = 0;
                
        end
    
        
        function closeWheel(obj)
            if strcmp(obj.connectionStatus, 'Open')
                delete(instrfind('tag', Devices.wheelNameTag)); 
                obj.connectionStatus = 'Closed';
                
            end
        end
        
        
    end
    
end



