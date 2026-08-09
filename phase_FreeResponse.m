function phase_FreeResponse(mouseId)
%% FROM TOUCH SCREEN PAPER...
% 2.4.1. Training stage 1: Free Reward (FR) The purpose of this phase of
% training was to associate the tone with the delivery of a reward, and to
% learn the location of the reward (reward spout). During this phase, mice
% learned to lick the reward spout to receive a reward.

% A trial started with a one second, 1 kHz tone followed by the delivery of
% a reward to the reward spout. Licking the reward spout triggered the
% start of a new trial after the mouse had discontinued licking the reward
% spout for at least 200 ms. This allowed for the mouse to consume the
% reward (Fig. 2a).

% There was no timeout and no stimuli were presented on the touchscreen
% during this phase of training.

% In order to advance, mice had to trigger more than 200 trials in an hour
% long session during two consecutive training days (Table 1).

% Mice were allowed to take up to a maximum of five training days to reach
% criteria, however the mice in this study completed this stage in an
% average of 2.1 ± 0.4 (mean ± S.D.) days (Fig. 3a, Table 1).

try
%%
delete(instrfindall)
ard                 = Arduino;  % opens arduino for lick sensing and reward distribution
log                 = DataLog(mouseId); % open new data file for mouse to log and save data
log.constrainLogRate(30);
log.writeToDataFile({'time', 'lick'})
phaseDuration       = 30*60;       % duration of phase in seconds (so 60 minutes);
phaseStartTime      = tic;      % start time of phase
phaseTimeElapsed    = 0;        % total time elapsed 
numRewardsConsumed  = 0;        % count number of rewards consumed (same as number of trials in this phase)
stopLickDuration    = .2;       % must stop licking the reward spout for at least 200 ms for next trial to start
loopRate            = 30;       % rate (num X per sec) of reading the arduino sensor 


%% TRAIN

while phaseTimeElapsed < phaseDuration
    
    % Start Trial: play reward tone & deliver reward
    inTrial = true;
    PlaySound.rewardtone;       
    ard.pulseValve;         
    
    lastLickTime = []; 
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
        log.writeToDataFile([phaseTimeElapsed, licked]);
        pause(1/loopRate);
               
    end
    


end

catch
    log.closeDataFile
    delete(instrfindall);
    fclose('all');    
end

end

