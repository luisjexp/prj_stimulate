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
    
	% CONNECT / CLOSE
	methods (Static)
		function msg = callArduino(obj)  

			tStart = tic;     
			while toc(tStart) < 30 
				try
					Arduino.closeArduino
					pause(.5);
					obj.Mod = serialport(Devices.arduinoPort, 9600,Tag= Devices.arduinoNameTag);              
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


			fprintf('\t%s\n', msg) ;
		end

		function closeArduino()
			delete(serialportfind('Tag',Devices.arduinoNameTag))   
			fprintf('\nARDUINO CLOSED')
		end
	end

	%---------------------------------
	% DEVICES INPUT + OUTPUT
	
    methods        
		%---------------------------------
		% BASIC READ STREAM
		function flushArduino(obj)
			flush(obj.Mod)
		end
		
		function readStream(obj,duration)
			arguments
				obj 
				duration = 2
			end
            tStart = tic;     

			while toc(tStart) < duration
				if ~isempty(obj.Mod) && strcmp(obj.Mod.Status, 'open')
					flush(obj.Mod);
					val = fscanf(obj.Mod, '%.05f');
				else
					val = [];
					disp('Cannot read value: Arduino not connected');
				end
				fprintf('%s',val)
				pause(.1);

			end
		end

		%---------------------------------
		% DEVICE 1 - JOY STICK
		function [xyb, msg, failed] = readXYB(obj)   
			flush(obj.Mod);

			if ~isempty(obj.Mod) && strcmp(obj.Mod.Status, 'open') 
				xyb = fscanf(obj.Mod, '%.05f');
				xyb = split(xyb, ",");
				xyb = str2double(xyb)';

				msg = 'success';
				failed = false;
				
			else
				xyb = [];
				msg = 'failed';
				failed = true;
			end
			
		end

		%---------------------------------
		% DEVICE 2 - VALVE
        % function [msg, failed] = triggerValve(obj)     
        %     if ~isempty(obj.Mod) && strcmp(obj.Mod.Status, 'open') 
        %         PlaySound.rewardtone;
        %         fwrite(obj.Mod, 'p');     
        %         msg = ('Valve triggered');
        %         failed = false;
        %     else
        %         failed = true;
        %         msg = ('Did not trigger valve: Arduino not connected');
        %     end
        %     disp(msg);
        % end
		% 
		% function pw = readPulseWidth(obj)
		% 	if ~isempty(obj.Mod) && strcmp(obj.Mod.Status, 'open') 
		% 		fwrite(obj.Mod, 'r');
		% 		pw = fscanf(obj.Mod, '%d');
		% 		obj.pulseWidth = pw;
		% 	else
		% 		pw = [];
		% 		disp('Cannot read sensor: Arduino not connected');
		% 	end 
		% end
		% 
		% function setPulseWidth(obj, desiredPw)
		% 	currentPw = readPulseWidth(obj);
		% 	d = desiredPw - currentPw;
		% 
		% 	if d ~= 0
		% 		if d>0
		% 			fwrite(obj.Mod, repmat('+',1, d));
		% 		elseif d<0
		% 			fwrite(obj.Mod, repmat('-',1, -d));                
		% 		end
		% 		pause(abs(d)*1/900);
		% 		obj.pulseWidth = readPulseWidth(obj);                 
		% 		fprintf('\nPW set to %d\n', obj.pulseWidth);
		% 	end
		% 
		% 
		% end
		% 
		% 
		% %---------------------------------
		% % DEVICE 3 - LICK SENSOR
        % function sensorState = readSensorState(obj)
        %     if ~isempty(obj.Mod) && strcmp(obj.Mod.Status, 'open') 
        %         fwrite(obj.Mod, 'w');
        %         sensorState     =  fread(obj.Mod,1,'uint8');
        %     else
        %         sensorState = 0;
        %         disp('Cannot read sensor: Arduino not connected');                
        %     end
		% 
        %     if strcmp(readKey, 'l') || strcmp(readKey, '1!') 
        %         sensorState = 1;
        %     end
		% 
        %     obj.sensorState = sensorState; 
		% 
        %     if obj.sensorState == 1 
        %         obj.lastTimeTouched = tic;                               
        %     end
        % end
		% 
        % function timeElapsed = readTimeElapsedSinceLastTouch(obj)                
        %     if ~isempty(obj.lastTimeTouched) 
        %         timeElapsed = toc(obj.lastTimeTouched);
        %         obj.timeElapsedSinceLastTouch = timeElapsed;
        %     end
		% 
		% 
        % end        
        
        
	end


    
    
end




