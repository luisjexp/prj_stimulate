function checkLickSensor
    ard = Arduino;

    if ~ard.isConnected 
       delete(instrfind('tag', 'arduinoLickPort'))
       ard = Arduino;
    end
        
    disp('Touch sensor to check if works. Press q key to exit') 
    disp('Will start in ')     
    for i = 1:3
        fprintf('...\t %d', i)
        pause(1)
    end
    
    while true
        fprintf('\n%d', ard.readSensorState')
        if ard.sensorState == 1
            disp('LICKED !!!')
            ard.triggerValve;         
            PlaySound.quickMediumPitch;   
        end
        if strcmp(readKey, 'q')
            fprintf('\nTest Exited\n')
           break;
        end           
    end


end