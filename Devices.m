classdef Devices
    
    properties (Constant)
        isDebugging = true;
        
        onTrachPc   = contains(cd, 'Trach');
        onLuisPc    = contains(cd, 'Luis') && ispc;
        onLuisMac   = contains(cd, 'luis') && ismac;
        
        luisMacIp   = '192.168.0.2';
        luisPcIp    = '192.168.0.3';

        trachPcPort = 30000;              
        luisMacPort = 50002;
        luisPcPort  = 50003;      
        wheelPort   = 'COM15'; 
        arduinoPort = 'COM17'; 
              
        arduinoNameTag  = 'arduinoLickPort';
        wheelNameTag    = 'ArCOM'; % name tag comes from bpod library
        stimCmdNameTag  = 'stimCommander';
        stimPrgNameTag  = 'stimProgram';
            
    end
    
    methods (Static)
        function resetAllPorts(obj)
            delete(instrfind('tag', obj.arduinoNameTag));
            delete(instrfind('tag', obj.wheelNameTag));
            delete(instrfind('tag', obj.stimCmdNameTag));
            delete(instrfind('tag', obj.stimPrgNameTag));
            fprintf('\nDeleted Instruments\n')
        end
    
    end
  
    

    

end

