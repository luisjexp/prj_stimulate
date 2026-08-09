function phase_mustTurn(mouseId)
%% FROM TOUCH SCREEN PAPER...
% 2.4.2. Training stage 2: Must Touch (MT)
% The goal of this phase was to associate touching the screen with
% delivery of a reward. 

% During this phase, mice had to touch any location on the screen at the
% front of the box to receive a reward.

% Random image pairs (pairs 1, 2, and 5 from Reference (Bussey et al.,
% 2008)) were presented on the touchscreen at the start of the trial with
% each image presented on a random side of the screen.

% After touching the screen, the images disappeared and a one second, 1 kHz
% tone sounded along with a reward.

% No timeouts were used during this phase of training.

% In this phase, cessation of licking the reward spout triggered a new
% trial which began with random image pairs presented on the touchscreen
% (Fig. 2b).

% After 2 consecutive training days of more than 200 initiated trials per
% hour, the mice progressed to the next phase of training (Table 1).

% For this phase of training, mice were again allowed up to a maximum of
% five training days to reach criteria, however the mice in this study
% completed this stage in an average of 2.4 ± 0.5 (mean ± S.D.) days
% (Fig. 3a, Table 1).

try
%%
% Screen
sca; delete(instrfindall);
drw = Draw(true);

% Arduino and Wheel
delete(instrfindall);
ard                 = Arduino;  % opens arduino for lick sensing and reward distribution
whl                 = Wheel;
loopRate            = 30;       % rate (num X per sec) of reading the arduino sensor and wheel 

% Data Writing 
log                 = DataLog(mouseId); % open new data file for mouse to log and save data 
log.constrainLogRate(30); 
log.writeToDataFile({'time', 'lick', 'whlPos'});

% Training 
phaseDuration       = 60*60;       % duration of phase in seconds (so 60 minutes);
phaseStartTime      = tic;      % start time of phase
phaseTimeElapsed    = 0;        % total time elapsed 
numRewardsConsumed  = 0;        % count number of rewards consumed (same as number of trials in this phase)
stopLickDuration    = 2;       % must stop licking the reward spout for at least 200 ms for next trial to start
turnSpeedThreshold  = 3;
killTask            = false;



%% TRAIN

while phaseTimeElapsed < phaseDuration && (killTask == false)
    % Display gray background and central dot
    drw.drawColoredBackground([128 128 128]); 
    drw.drawCentralDot(15);
    drw.flipScreen;
    
    % read the wheel to check how fast its turning. If turn is fast enough 
    % then start the trial       
    waitingForWheelTurn = true;
    abs(whl.readTurnSpeed);
    while waitingForWheelTurn
        licked = (ard.readSensorState == 1); % also read licks for data        
        turnedWheel = abs(whl.readTurnSpeed) > turnSpeedThreshold;
        fprintf('%d ', turnedWheel)
        if turnedWheel        
            for i = 1:10; 
                PlaySound.doubleLowPitch;            
            end
            waitingForWheelTurn = false;
        end
        
        log.writeToDataFile([phaseTimeElapsed, licked, whl.currentPosition]);
        
        if strcmp(readKey, 'esc')
           killTask = true;
           break;
        end  
        
    end
    
    % Initialize trial: play tone/ deliver reward / show green
    % screen

    PlaySound.rewardtone;     
    ard.pulseValve;         
    drw.drawColoredBackground([10,255,50])
    drw.flipScreen;     
    inTrial      = true & (killTask == false);
    lastLickTime = nan; 
    
    while inTrial
        % read the sensor to check if the mouse licks (sensor state will
        % equal 1) if so record time of lick
        licked = (ard.readSensorState == 1);
        if  licked
            lastLickTime = GetSecs;
            PlaySound.quickLowPitch;
        end

        % get the amount of time elapsed since last lick. if mouse has not
        % licked for 200 ms then increment reward count and move on to next
        % trial
        timeElapsedSinceLastLick = GetSecs - lastLickTime;  
        if timeElapsedSinceLastLick > stopLickDuration   
            numRewardsConsumed = numRewardsConsumed + 1;            
            inTrial = false;
        end
        % Record time elapsed, log if mouse licked or not and the time
        % stamp. Then pause for 1/loopRate seconds before reading arduino
        % sensor again
        phaseTimeElapsed = toc(phaseStartTime); 
        log.writeToDataFile([phaseTimeElapsed, licked, whl.currentPosition]);
        pause(1/loopRate);
        
        if strcmp(readKey, 'esc')
           killTask = true;
           break;
        end          
               
    end
    

    
end

drw.closeScreen
delete(instrfindall)
fclose('all');

catch ME
    delete(instrfindall)
    fclose('all');
    sca;
    rethrow(ME)
    

end

end