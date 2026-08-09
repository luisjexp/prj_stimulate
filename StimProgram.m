classdef StimProgram < handle & StimScreen & StimServer & DotPop
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
     
    properties
        setThenShow = true;
        msgFromCmd
        previousMsg
    end
    
    methods

        function obj = StimProgram
            try
                obj.start;
            catch ME                
                obj.closeScreen;
                obj.closeServer ;                    
                fprintf('\n***ERROR in Stim Program but Safely Closed***\n')
                rethrow(ME)
            end 
        end
        
        function start(obj)
            obj.openWindow;
            obj.intializeDotPop;
            obj.openServer;            
            obj.msgFromCmd = StimMessages.view_waitScreen;
            while true
                switch obj.msgFromCmd  
                    case StimMessages.view_waitScreen
                        obj.waitscreen;
                    case StimMessages.view_dotMovie
                        obj.moco;
                    case StimMessages.set_randDotDirection
                        obj.setRandDirection
                    case StimMessages.set_specDotDirection
                        obj.setSpecDirection;
                    case StimMessages.set_coherence
                        obj.setcoherence;  
                    case StimMessages.set_lifeTime
                        obj.setlifetime;
                    case StimMessages.view_whiteScreen
                        obj.coloredScreen([255 255 255]);
                    case StimMessages.view_grayScreen
                        obj.coloredScreen([127 127 127]); 
                    case StimMessages.set_newMessage
                        obj.writenewmessage;
                    case StimMessages.get_coherence
                        obj.sendPropertyValue('coherence');
                    case StimMessages.get_lifeTime
                         obj.sendPropertyValue('lifetime');   
                    case StimMessages.get_currentDirection
                         obj.sendPropertyValue('currentDirection');                           
                    case StimMessages.shutDown
                        obj.shutdown ;
                end
            end
        end
    
        function obj = waitscreen(obj)
            tstring = cellfun(@(s) sprintf('\n%s', s) , StimMessages.getAllValidMessages, 'uniformoutput', false);
            tstring = [tstring{:}];
            while true
                obj.drawCenterText(sprintf('Waiting for commands:%s',tstring)) ;                 
                obj.flipScreen; 
                obj.msgFromCmd = obj.readMessageIfAvailable;
                if any(strcmp(obj.msgFromCmd, StimMessages.getAllValidMessages))
                   break 
                end             
            end
        end
        
        function obj = setcoherence(obj)
            while true
                obj.drawCenterText('Enter coherence [value from 0 to 1]...') ;                 
                obj.flipScreen;    
                obj.msgFromCmd = obj.readMessageIfAvailable;
                c = str2double(obj.msgFromCmd);
                disp(c)
                if ~isempty(c) && ~isnan(c)
                    numCoherentDots = round(c*obj.numDots);
                    obj.setCoherence(numCoherentDots);
                    if obj.setThenShow
                        obj.msgFromCmd = StimMessages.view_dotMovie;
                    else
                        obj.drawCenterText(sprintf('Coherence Set to %.02f',c));                                   
                        obj.flipScreen;                          
                        obj.msgFromCmd = StimMessages.view_waitScreen;
                        pause(1.25)
                    end
                    break 
                end 
            end          
        end
        
        function obj = setlifetime(obj)
            while true
                obj.drawCenterText('Enter life time value [in frames from 1 to inf]...') ;                 
                obj.flipScreen;    
                obj.msgFromCmd = obj.readMessageIfAvailable;
                c = str2double(obj.msgFromCmd);
                if ~isempty(c) && ~isnan(c) 
                    obj.setNewLifeTime(c);
                    if obj.setThenShow
                        obj.msgFromCmd = StimMessages.view_dotMovie;
                    else
                        obj.drawCenterText(sprintf('Life Time Set to %d frames',c))  ;                                   
                        obj.flipScreen;                         
                        obj.msgFromCmd = StimMessages.view_waitScreen;
                        pause(1.25)
                    end
                    break 
                end 
            end          
        end

        function obj = setSpecDirection(obj)
            while true
                obj.drawCenterText('Enter Direction Value [0 or 180]...') ;                 
                obj.flipScreen;    
                obj.msgFromCmd = obj.readMessageIfAvailable;
                c = str2double(obj.msgFromCmd);
                if ~isempty(c) && ~isnan(c)  && (c== 0 || c==180) 
                    obj.setNewSignalDirection(c);
                    if obj.setThenShow
                        obj.msgFromCmd = StimMessages.view_dotMovie;
                    else
                        obj.drawCenterText(sprintf('Direction to %d Degrees',c))  ;                                   
                        obj.flipScreen;                         
                        obj.msgFromCmd = StimMessages.view_waitScreen;
                        pause(1.25)
                    end
                    break 
                end 
            end          
        end
        
        
        function setRandDirection(obj)
            newDir = obj.setNewSignalDirectionAtRandom;
            obj.write2Commander(num2str(newDir));
            if obj.setThenShow
                obj.msgFromCmd = StimMessages.view_dotMovie;
            else                       
                obj.msgFromCmd = StimMessages.view_waitScreen;
            end            
        end
        
        function sendPropertyValue(obj, prop)
            switch prop
                case 'lifetime'
                    obj.write2Commander(num2str(obj.lifeTime));
                    obj.msgFromCmd = StimMessages.view_waitScreen;
                case 'coherence'
                    c = num2str(round(100*obj.coherence/obj.numDots));
                    obj.write2Commander(c);
                    obj.msgFromCmd = StimMessages.view_waitScreen;   
                case 'currentDirection'
                    obj.signalDots_direction
                    obj.write2Commander(num2str(obj.signalDots_direction));
                    obj.msgFromCmd = StimMessages.view_waitScreen;                    
            end
            
        end

        function obj = moco(obj)
            tStart = tic;
            Screen('FillRect', obj.windowPtr, [127 127 127], obj.dispRect); 
            while true
                Screen('FillOval', obj.windowPtr, obj.dotColor, obj.getDotRectList);
                tstring = sprintf('NumDots: %d\nCoherence: %.01f\nLifeTime: %d (f)\nTimeElapsed: %.01f',...
                                obj.numDots, obj.coherence/obj.numDots, obj.lifeTime, toc(tStart));                               
                DrawFormattedText(obj.windowPtr, tstring,40, 40, [255 0 0]);    
                obj.flipScreen;    
                obj.moveDots;
                obj.msgFromCmd = obj.readMessageIfAvailable;
                if any(strcmp(obj.msgFromCmd, StimMessages.getAllValidMessages))
                   break 
                end 
            end                
        
        end
        
        function obj = coloredScreen(obj, color)
            Screen('FillRect', obj.windowPtr, color, obj.dispRect);
            while true
                obj.flipScreen; 
                obj.msgFromCmd = obj.readMessageIfAvailable;
                if any(strcmp(obj.msgFromCmd, StimMessages.getAllValidMessages))
                   break 
                end    
            end
        end
        
        
        function obj = drawCenterText(obj, tstring)
            Screen('TextSize', obj.windowPtr, 15);                
            Screen('FillRect', obj.windowPtr, [0 0 0], obj.dispRect);  
            DrawFormattedText(obj.windowPtr, tstring,'center', 'center', [255 0 0])     ;       
        end        
        
        function obj = writenewmessage(obj)
            while true
                obj.drawCenterText('Waiting On Message from Commander');
                obj.flipScreen;                
                obj.msgFromCmd = obj.readMessageIfAvailable;
                if ~isempty(obj.msgFromCmd)
                    messageFromCmd = obj.msgFromCmd;
                    break;
                end    
            end 
            
            while true
                obj.drawCenterText(messageFromCmd);
                obj.flipScreen;
                obj.msgFromCmd = obj.readMessageIfAvailable;
                if any(strcmp(obj.msgFromCmd, StimMessages.getAllValidMessages))
                   break; 
                end                  
            end            
            
        end
        
        % Override Dot Pop initialization
        function intializeDotPop(obj)
            obj.maxX = obj.screenRect(3);
            obj.maxY = obj.screenRect(4);
            screenArea  = obj.maxX* obj.maxY; 
            dotArea     = pi*obj.dotRadius^2 ;
            obj.numDots = round((.20*screenArea)/dotArea);
            obj.coherence  = round(.5*obj.numDots);   
            obj.Dots    = repmat( struct('posIdx', [], 'rect', [], 'direction', [], 'age', 0, 'pathY', [], 'pathX', []), obj.numDots, 1);
            obj.randomizeAges;
            obj.setCoherence(obj.coherence)   ;          
        
        end
    
        function shutdown(obj)  
            obj.msgFromCmd = StimMessages.view_whiteScreen;
            if Devices.onTrachPc
                obj.closeScreen
                obj.closeServer 
                instrreset;                
                disp('Matlab Will Close...')
                pause(.5)
                exit;
            end    
        end
    end
     
     
     

    
end


