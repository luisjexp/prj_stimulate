classdef StimScreen < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        screenRect  = get(0,'screensize');                      % size of computer display screen
        windowPtr;
        dispRect;
        dispCx;
        dispCy;
        lastFlipTime;
        status = 'closed';
        
        flipCount = 0;
        minFlipInterval = 1/60 -.008;
    end
    
    methods 
        
    function obj = openWindow(obj)
        sca;
        if Devices.isDebugging
            rect = [obj.screenRect(3)-500 0 obj.screenRect(3) obj.screenRect(4)-200];               
        else
            rect = [];
        end
        scrnNum = Screen('Screens');
        [obj.windowPtr, obj.dispRect] = Screen('OpenWindow',scrnNum, 127*[1 1 1], rect);
        Screen('MATLABToFront')
        obj.status = 'open';                        
        Screen('Preference', 'SkipSyncTests', 1);
        Screen('Preference', 'Verbosity', 0);  
        obj.dispCx = mean(obj.dispRect([1 3]));         % center x of display (not the screen), with respect to display
        obj.dispCy = mean(obj.dispRect([2 4]));         % center y of display (not the screen), with respect to display
        obj.lastFlipTime = Screen('Flip', obj.windowPtr);   % flips screen then returns time of flip        
        Screen('TextSize', obj.windowPtr, 12);
    end
        
    function obj = flipScreen(obj)
        obj.lastFlipTime    = Screen('Flip',obj.windowPtr, obj.minFlipInterval ); 
        obj.flipCount       = obj.flipCount + 1;            
    end

    function obj = closeScreen(obj)
        Screen('Close', obj.windowPtr); 
        obj.status = 'closed';                        
    end    
        
        
    end
               
    
end

