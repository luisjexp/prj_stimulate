classdef PlaySound
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods (Static)
        
        function rewardtone
            sound(.1*sind(75*(1:200)));
        end
        
        function doubleLowPitch
            sound(sind([10*(1:500), zeros(1,500),10*(1:500)]));
        end
        
        function quickMediumPitch
            sound(.1*sind(75*(1:200)));
        end
        
        function quickLowPitch
            sound(2*sind(5*(1:200)))
        end
        
        
        
    end
    
end

