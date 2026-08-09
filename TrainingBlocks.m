classdef TrainingBlocks < handle
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        currentBlock = 1;
        numBlocks
        numRepeats = 0;
        maxRepeats = inf;
    end
    
    methods
        
        function newBlock = move2nextBlock(obj)
            newBlock = obj.currentBlock + 1;
            if newBlock > obj.numBlocks
               newBlock = 1; 
               obj.numRepeats = obj.numRepeats + 1;
            end
            obj.currentBlock = newBlock;
        end
        
        function set(obj, name, value)
            switch name
                case 'currentBlock' 
                    obj.currentBlock = value;
                case 'maxRepeats'
                    obj.maxRepeats = value;
                case 'numRepeats'
                    obj.numRepeats = value;
                case 'numBlocks'
                    obj.numBlocks = value;
                otherwise
                    error('%s is not a valid property', name);
            end         
        end
        
    end
end

