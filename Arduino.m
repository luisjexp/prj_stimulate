classdef Arduino < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Mod
        pulseWidth
        sensorState
        lastTimeTouched
        timeElapsedSinceLastTouch        
    end
    
    methods
        
        function msg = callArduino(obj)  
            delete(instrfind('tag', Devices.arduinoNameTag));
            obj.Mod = serial(Devices.arduinoPort, 'tag', Devices.arduinoNameTag);              
            tStart = tic;     
            while toc(tStart) < 30 && Devices.onTrachPc
                try
                    delete(instrfind('tag', Devices.arduinoNameTag));
                    pause(.5);
                    obj.Mod = serial(Devices.arduinoPort, 'tag', Devices.arduinoNameTag);                       
                    fopen(obj.Mod);                     
                catch ME
                    disp(ME)
                end  
                
                if strcmp(obj.Mod.Status, 'open')
                    msg = 'Arduino CALL SUCCESSFULL :)';
                    pause(1); % pause breifly once connected, otherwise cant read sensor
                    obj.sensorState = 0;                          
                    break;
                else
                    msg = 'Arduino CALL FAILED';
                    disp(msg);
                    disp('   will try again...');
                end  
                pause(1.5);
            end
                
            if ~Devices.onTrachPc
                msg = 'DID NOT ATTEMPT CALL: Arduino not expected on this device. Use [l] key to mimic touch.';
            end
            obj.readSensorState

            fprintf('\t%s\n', msg) ;
        end
        
        function [msg, failed] = triggerValve(obj)     
            if ~isempty(obj.Mod) && strcmp(obj.Mod.Status, 'open') 
                PlaySound.rewardtone;
                fwrite(obj.Mod, 'p');     
                msg = ('Valve triggered');
                failed = false;
            else
                failed = true;
                msg = ('Did not trigger valve: Arduino not connected');
            end
            disp(msg);
        end
        
        function sensorState = readSensorState(obj)
            if ~isempty(obj.Mod) && strcmp(obj.Mod.Status, 'open') 
                fwrite(obj.Mod, 'w');
                sensorState     =  fread(obj.Mod,1,'uint8');
            else
                sensorState = 0;
                disp('Cannot read sensor: Arduino not connected');                
            end
            
            if strcmp(readKey, 'l') 
                sensorState = 1;
            end
            
            obj.sensorState = sensorState; 
            
            if obj.sensorState == 1 
                obj.lastTimeTouched = tic;                               
            end
        end
        
        function timeElapsed = readTimeElapsedSinceLastTouch(obj)                
            if ~isempty(obj.lastTimeTouched) 
                timeElapsed = toc(obj.lastTimeTouched);
                obj.timeElapsedSinceLastTouch = timeElapsed;
            end
            
            
        end        
        
        function pw = readPulseWidth(obj)
            if ~isempty(obj.Mod) && strcmp(obj.Mod.Status, 'open') 
                fwrite(obj.Mod, 'r');
                pw = fscanf(obj.Mod, '%d');
                obj.pulseWidth = pw;
            else
                pw = [];
                disp('Cannot read sensor: Arduino not connected');
            end 
        end
        
        function setPulseWidth(obj, desiredPw)
            currentPw = readPulseWidth(obj);
            d = desiredPw - currentPw;
            
            if d ~= 0
                if d>0
                    fwrite(obj.Mod, repmat('+',1, d));
                elseif d<0
                    fwrite(obj.Mod, repmat('-',1, -d));                
                end
                pause(abs(d)*1/900);
                obj.pulseWidth = readPulseWidth(obj);                 
                fprintf('\nPW set to %d\n', obj.pulseWidth);
            end
            
            
        end
        
        
        function closeArduino(obj)
            if ~isempty(obj.Mod) && strcmp(obj.Mod.Status, 'open') 
                fclose(obj.Mod);
                delete(instrfind('tag', Devices.wheelNameTag)); 
            end            
        end
        
        
            
    end
    
    
end




