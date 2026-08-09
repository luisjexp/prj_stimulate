classdef TrainingTime < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        tStart
        tElapsed
    end
    
    properties (Constant)
        maxTrainingTime = 120;        
    end
    
    methods
        function resetTimeStart(obj)
            obj.tStart = tic;
            obj.tElapsed = 0;
        end
        
        function tElapsed = readTimeElapsed(obj)
                tElapsed = toc(obj.tStart);
                obj.tElapsed = tElapsed;
        end
    end
end

