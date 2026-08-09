classdef CommonBlocks < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods (Static)
        function app = waitForLick(app, currentBlock, nextBlock)
            % Waits For a Lick.
            % Once lick occurs sets current block to newBlock            
            while app.blcks.currentBlock == currentBlock && app.phase.keepTraining()
                app.time.readTimeElapsed;                        
                app.readBehavior;
                if app.ard.sensorState == 1
                    set(app.blcks, 'currentBlock', nextBlock);
                end
                pause(1/60);                                                                    
            end 
        end
        
        function app = waitTilCalmForNSeconds(app, N, currentBlock, nextBlock)
            while app.blcks.currentBlock == 2 && app.phase.keepTraining()
                app.time.readTimeElapsed;                        
                app.readBehavior;
                if app.ard.timeElapsedSinceLastTouch > N
                    set(app.blcks, 'currentBlock', 3)
                end
                pause(1/60);                        
            end
        end
        

    end
end

