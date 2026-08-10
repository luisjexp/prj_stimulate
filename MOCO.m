classdef Moco_r2017b_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        DevicesPanel                   matlab.ui.container.Panel
        StimArmed_lamp                 matlab.ui.control.Lamp
        StimulusLabel                  matlab.ui.control.Label
        WheelArmed_lamp                matlab.ui.control.Lamp
        WheelLampLabel                 matlab.ui.control.Label
        ArduinoArmed_lamp              matlab.ui.control.Lamp
        ArduinoLampLabel               matlab.ui.control.Label
        ArmDevices_swtch               matlab.ui.control.Switch
        PhasesPanel                    matlab.ui.container.Panel
        Panel_4                        matlab.ui.container.Panel
        ElapsedtimeLabel               matlab.ui.control.Label
        timeElapsed_lbl                matlab.ui.control.Label
        Panel_3                        matlab.ui.container.Panel
        LogInProgress_lbl              matlab.ui.control.Label
        MouseID_txtfld                 matlab.ui.control.EditField
        MouseIDLabel                   matlab.ui.control.Label
        TrainingPhase_tabgrp           matlab.ui.container.TabGroup
        PhasesTab                      matlab.ui.container.Tab
        TrainPhase_Manual_swtch        matlab.ui.control.ToggleSwitch
        ManualLabel                    matlab.ui.control.Label
        TrainPhase_VarCoherence_swtch  matlab.ui.control.ToggleSwitch
        VariedCoherenceLabel_2         matlab.ui.control.Label
        TrainPhase_FixedCoherence_swtch  matlab.ui.control.ToggleSwitch
        FixedCoherenceLabel            matlab.ui.control.Label
        TrainPhase_MustTurn_swtch      matlab.ui.control.ToggleSwitch
        MustTurnSwitchLabel            matlab.ui.control.Label
        TrainPhase_FreeReward_swtch    matlab.ui.control.ToggleSwitch
        FreeRewardLabel                matlab.ui.control.Label
        WheelSensorPanel               matlab.ui.container.Panel
        LickLabel                      matlab.ui.control.Label
        SensorState_lamp               matlab.ui.control.Lamp
        WheelTurnThreshold             matlab.ui.control.Spinner
        TurnThresholdLabel             matlab.ui.control.Label
        WheelAxis                      matlab.ui.control.UIAxes
        NotificationsPanel             matlab.ui.container.Panel
        NotificationCenter_4           matlab.ui.control.Label
        NotificationCenter_3           matlab.ui.control.Label
        NotificationCenter_2           matlab.ui.control.Label
        NotificationCenter_1           matlab.ui.control.Label
        Notifications_lbl              matlab.ui.control.Label
        StimulusPanel                  matlab.ui.container.Panel
        SetRandomDirection_btn         matlab.ui.control.Button
        SetDotDirection_spnr           matlab.ui.control.Spinner
        DotDirectionSpinnerLabel       matlab.ui.control.Label
        SetLifeTime_spnr               matlab.ui.control.Spinner
        LifeTimeframesLabel            matlab.ui.control.Label
        SetCoherence_spnr              matlab.ui.control.Spinner
        CoherenceLabel                 matlab.ui.control.Label
        StimViews_list                 matlab.ui.control.ListBox
        ViewsListBoxLabel              matlab.ui.control.Label
        RewardPanel_2                  matlab.ui.container.Panel
        PulseLabel                     matlab.ui.control.Label
        PulseValveKx_bttn              matlab.ui.control.Button
        PulseWidth_spnr                matlab.ui.control.Spinner
        PulseWidthmsLabel              matlab.ui.control.Label
        ulPerReward_editFld            matlab.ui.control.NumericEditField
        ulPulseLabel                   matlab.ui.control.Label
        PulseValveOnce_bttn            matlab.ui.control.Button
    end


    properties (Access = public)
        ard     = Arduino;       % Arduino/lickport
        stmCmd  = StimCommander; % Stimulus Commander
        whl     = Wheel;
        time    = TrainingTime; % Training timing variables
        blcks   = TrainingBlocks;
        log     = DataLog;
        phase  
    end

    methods (Access = private)
        % Mark: Training Tools
        
        % Reads touches and wheel position
        function readBehavior(app) 
            app.time.readTimeElapsed;                        
            % Read behavior
            app.whl.readWheelPosition;
            app.ard.readSensorState; 
            app.ard.readTimeElapsedSinceLastTouch;
            
            % Update Graphics
            app.SensorState_lamp.Color = [0 .5 1] .* app.ard.sensorState;               
            app.WheelAxis.Children(1).XData = app.whl.currentPosition; 
            app.timeElapsed_lbl.Text = num2str(app.time.tElapsed, '%.01f');
            drawnow;  
            
            % Log Data
            if app.ard.sensorState == 1
                app.log.write2DataFile(app.time.tElapsed, DataLog.sensorFile_extension);
            end
            
            if app.whl.didTurn
                app.log.write2DataFile([app.time.tElapsed, app.whl.currentPosition], DataLog.wheelFile_extension);    
            end
        end    
        
        % Check if turn correct
        function bool = turnDirEqualsWheelDir(app)
            if (app.whl.currentPosition > 0) && (app.SetDotDirection_spnr.Value == 0) ||...
               (app.whl.currentPosition < 0) && (app.SetDotDirection_spnr.Value == 180)
                bool = true;
            else
               bool = false; 
            end
            
        end    
        
        function zeroWheel(app)
            zero(app.whl); 
            app.log.write2DataFile({app.time.tElapsed, 'Wheel'  ,'zerod', nan}, DataLog.systemFile_extension ) ;            
        end
    end


    methods (Access = private)  
                
        %% Mark: Notifications Colors
        function color = getFontColor(app, severity)
            if severity >= -1 && severity < -.5
                color = [0 .75 0.05];   % Green
            elseif severity > -.5 && severity < 0
                color = [0 .3 0];       % Dark Green
            elseif severity == 0
                color = [0 0 0];        % Black
            elseif severity > 0 && severity < .5
                color = [1 .75 .5];     % Orange
            elseif severity > .5 && severity <= 1
                color = [0.75 0 .05];    % Red                
            else 
                error('severity value must be between 0 and 1')
            end
            
        end        
        
        % Mark: UPDATE REWARD AMOUNT 
        function rewardAmountInMicroLtrs_string = updateMicroltrAmount(app, rewardCountTextString)
            rewardAmountInMicroLtrs_string      = num2str(str2double(rewardCountTextString) * app.ulPerReward_editFld.Value);
        end
        
        % Mark: Update Alert Center Text
        function dispAlert(app, fontColor, tString)

            app.NotificationCenter_4.Text      = app.NotificationCenter_3.Text;
            app.NotificationCenter_4.FontColor = app.NotificationCenter_3.FontColor; 
            
            app.NotificationCenter_3.Text      = app.NotificationCenter_2.Text;
            app.NotificationCenter_3.FontColor = app.NotificationCenter_2.FontColor; 

            app.NotificationCenter_2.Text      = app.NotificationCenter_1.Text;
            app.NotificationCenter_2.FontColor = app.NotificationCenter_1.FontColor; 
            
            app.NotificationCenter_1.Text      = tString;
            app.NotificationCenter_1.FontColor = fontColor;                  
            
        end
 
        % Mark: Update Stimulus from Lifetime and Coherence Spinner    
        function updateMocoParameterVals(app, parameter)
            switch parameter
                case 'coherence'
                    newValue    = num2str(app.SetCoherence_spnr.Value/100);
                    setMessage  = StimMessages.set_coherence;
                    getMessage  = StimMessages.get_coherence; 
                case 'lifetime'
                    newValue    = num2str(app.SetLifeTime_spnr.Value);
                    setMessage  = StimMessages.set_lifeTime;
                    getMessage  = StimMessages.get_lifeTime; 
                case 'direction'
                    newValue    = num2str(app.SetDotDirection_spnr.Value);
                    setMessage  = StimMessages.set_specDotDirection;
                    getMessage  = StimMessages.get_currentDirection ;                         
            end
    
            app.stmCmd.Write(setMessage); pause(.025);
            app.stmCmd.Write(newValue);   pause(.025);            
            app.stmCmd.Write(getMessage);
            [retreivedValue, info, updateFailed]= app.stmCmd.waitForMessage(2);
            retreivedValue =  str2double(retreivedValue);
            
           if updateFailed
               if strcmp(parameter, 'coherence')
                    retreivedValue  = app.SetCoherence_spnr.Value;                   
               else
                    retreivedValue  = str2double(newValue);
               end
                app.dispAlert(app.getFontColor(1), sprintf('Could not update %s | %s', parameter, info));
                app.log.write2DataFile({app.time.tElapsed, 'Stim', sprintf('%sChangeAttemptFailed',parameter), retreivedValue}, DataLog.systemFile_extension );                           
           else
                app.dispAlert(app.getFontColor(0), sprintf('%s succesfully updated', parameter));
                app.log.write2DataFile({app.time.tElapsed, 'Stim', sprintf('%sChangeAttemptSuccess',parameter), retreivedValue}, DataLog.systemFile_extension );                              
           end
           
           switch parameter
               case 'coherence'
                   app.SetCoherence_spnr.Value     = retreivedValue;
                   app.SetCoherence_spnr.FontColor = app.getFontColor(1*updateFailed); 
               case 'lifetime'
                    app.SetLifeTime_spnr.Value      = retreivedValue;
                    app.SetLifeTime_spnr.FontColor  = app.getFontColor(1*updateFailed);  
               case 'direction'
                    app.SetDotDirection_spnr.Value  = retreivedValue;
                    app.SetDotDirection_spnr.FontColor  = app.getFontColor(1*updateFailed); 
           end       

            % Continue showing selected View
            showView(app, app.StimViews_list.Value)  
            
        end
        
        % Mark: Intiatiate Training Phases
        function intitiatePhase(app)
            app.phase.phaseSwitchObj = getOnPhaseSwitchObject(app); 
            app.phase.currentPhase   = app.phase.phaseSwitchObj.Tag;
            app.phase.abort          = false;            
            app.phase.keepTraining   = @() (app.isvalid) && ( strcmp(app.phase.phaseSwitchObj.Value , 'Go') ) &&...
                                          (~app.phase.abort) && (app.time.tElapsed < TrainingTime.maxTrainingTime);

            % Prepare Files for Loging
            app.time.resetTimeStart;               
            app.log.closeDataFileSet ;              
            app.log = DataLog;
            mouseID = app.MouseID_txtfld.Value;

            if isempty(mouseID)
                app.phase.abort = true;
                app.phase.phaseSwitchObj.Value = 'End';
                app.dispAlert(app.getFontColor(1), 'ENTER MOUSE ID BEFORE BEGIN TRAINING!!!');
                return;
            end
            openFileDataSet(app.log, mouseID);
            app.LogInProgress_lbl.Text =  sprintf('Logging: #%d', str2double(app.log.numericId));
            write2DataFile(app.log, {app.time.tElapsed, 'Phase'  ,sprintf('begin%s', app.phase.currentPhase)  ,nan}, DataLog.systemFile_extension );
            armDevicesForTraining(app);  % Call Arduino, Wheel and Stim
        end
        
        
        function finalizePhase(app)           
            app.disarmDevicesForTraining;                           
            if app.phase.abort 
                event = 'aborted';
            else
                event = 'ended';
                app.phase.phaseSwitchObj.Value = 'End';
            end
            
            fontColor = app.getFontColor(1 * app.phase.abort );
            app.log.write2DataFile({app.time.tElapsed, 'Phase'  ,sprintf('%s%s', event, app.phase.currentPhase) ,nan}, DataLog.systemFile_extension );
            
            app.dispAlert(fontColor, sprintf('%s%s', event, app.phase.currentPhase)); 
            app.log.closeDataFileSet;          
            app.LogInProgress_lbl.Text =  sprintf('Closed Log: %d', str2double(app.log.numericId));
            
        end
        
        function onSwitch = getOnPhaseSwitchObject(app)
            onSwitch = findall(app.TrainingPhase_tabgrp, 'Type', 'uitoggleswitch');            
            onSwitch = onSwitch( contains({onSwitch(:).Value}, 'Go') );           
        end
        
        function disableTrainPhaseSwitches(app, OnOrOff)
            swtchObj = findall(app.TrainingPhase_tabgrp, 'Type', 'uitoggleswitch');
            if strcmp(OnOrOff, 'Off') || strcmp(OnOrOff,'On')   
                for i = 1:numel(swtchObj)
                    if strcmp(swtchObj(i).Value, 'End')
                        swtchObj(i).Enable = OnOrOff;
                    end
                end
            else
                error('only ''On'' or ''Off'' allowed as input');
            end    
            
        end
        
        function armDevicesForTraining(app)
            app.ArmDevices_swtch.Value = 'Arm';
            app.disableTrainPhaseSwitches('Off');                
                app.armWheel;       % Arm Wheel
                app.armArduino;     % Arm Arduino
                app.armStimProgram; % Arm Stimulus
            app.dispAlert(app.getFontColor(-1), {'Devices Armed'});     
            app.ArmDevices_swtch.Enable = 'Off';
        end

        function disarmDevicesForTraining(app)
            app.ArmDevices_swtch.Value = 'Off';
            app.disableTrainPhaseSwitches('On');
                app.disarmWheel;       % Arm Wheel
                app.disarmArduino;     % Arm Arduino
                app.disarmStimProgram; % Arm Stimulus
            app.dispAlert(app.getFontColor(-1), {'Devices Disarmed'});   
            app.ArmDevices_swtch.Enable = 'Off';
        end        

        
        % Mark: Open Wheel Plot
        function wheelPlotOpen(app)
            cla(app.WheelAxis);            
            app.WheelAxis.DataAspectRatioMode = 'auto'  ;
            app.WheelAxis.PlotBoxAspectRatioMode = 'auto';
            app.WheelAxis.CameraViewAngleMode = 'auto';
            
            hold(app.WheelAxis, 'on');          
            plot(app.WheelAxis, -app.WheelTurnThreshold.Value*[1 1] ,  app.WheelAxis.YLim,...
                  'b+', 'markeredgecolor', 'b','markerfacecolor', 'b', 'markersize', 25); 
            plot(app.WheelAxis, app.WheelTurnThreshold.Value*[1 1] ,  app.WheelAxis.YLim,...
                  'b+', 'markeredgecolor', 'b','markerfacecolor', 'b', 'markersize', 25);
            plot(app.WheelAxis, nan, 0, 'c.', 'markersize', 35);
            hold(app.WheelAxis, 'off');
        end        
        
        function wheelPlotClose(app)
           cla(app.WheelAxis);
           text(app.WheelAxis, .5, .5, 'NOT READING WHEEL', 'units', 'normalized', 'horizontalalignment', 'center') ;           
        end
        
        

        % Mark: Arm And Disarm the Wheel
        function armWheel(app)
            app.dispAlert([0 0 0], 'Calling wheel...');  
            msg = app.whl.callWheel;    
            if strcmp(app.whl.connectionStatus, 'Open')
                notifColor = app.getFontColor(-1);
                app.log.write2DataFile({app.time.tElapsed, 'Wheel', 'contactSuccessfull', nan}, DataLog.systemFile_extension) ;             
                app.log.write2DataFile({app.time.tElapsed, 'Wheel', 'turnThreshold', app.WheelTurnThreshold.Value},  DataLog.systemFile_extension) ; 
            else          
                app.log.write2DataFile({app.time.tElapsed, 'Wheel', 'contactFailed', nan}, DataLog.systemFile_extension) ;                        
                notifColor = app.getFontColor(.25); 
            end     
            app.dispAlert(notifColor, msg);
            app.WheelArmed_lamp.Color = notifColor;
            app.wheelPlotOpen;     
        end
        
        function disarmWheel(app)
            app.whl.closeWheel;   
            app.WheelArmed_lamp.Color = app.getFontColor(0);                
            app.wheelPlotClose;  
            app.dispAlert([0 0 0], 'Wheel disarmed');
            app.log.write2DataFile({app.time.tElapsed, 'Wheel', 'connectionClosed', nan}, DataLog.systemFile_extension) ;                
        end
        
        % Mark: Arm and Disarm Arduino
        function armArduino(app)
            app.dispAlert([0 0 0], 'Calling Arduino');
            msg = app.ard.callArduino;     
            if strcmp(app.ard.Mod.Status, 'open')
                notifColor = app.getFontColor(-1);
                app.PulseWidth_spnr.Value = app.ard.readPulseWidth; 
                app.log.write2DataFile({app.time.tElapsed, 'Arduino', 'contactSuccessfull', nan}, DataLog.systemFile_extension) ;  
                app.log.write2DataFile({app.time.tElapsed, 'Arduino', 'PWchanged', app.PulseWidth_spnr.Value}, DataLog.systemFile_extension) ;  
            elseif strcmp(app.ard.Mod.Status, 'closed')
                app.log.write2DataFile({app.time.tElapsed, 'Arduino', 'contactFailed', nan}, DataLog.systemFile_extension) ;           
                notifColor = app.getFontColor(.25);                    
            end   
            
            app.dispAlert(notifColor, msg);
            app.ArduinoArmed_lamp.Color = notifColor;
            
            app.PulseWidth_spnr.Enable       = 'On';            
            app.PulseWidth_spnr.Editable     = 'Off';       
            app.PulseValveOnce_bttn.Enable     = 'On';
            app.PulseValveKx_bttn.Enable     = 'On';
        end
        
        function disarmArduino(app) 
            app.ard.closeArduino;
            disableArduinoButtons(app)
            app.ArduinoArmed_lamp.Color = [0 0 0];   
            app.dispAlert([0 0 0], 'Disarmed Arduino'); 
            app.log.write2DataFile({app.time.tElapsed, 'Arduino', 'connectionClosed',nan}, DataLog.systemFile_extension)  ;           
            function disableArduinoButtons(app)
                app.PulseWidth_spnr.Enable       = 'Off';            
                app.PulseWidth_spnr.Editable     = 'Off';       
                app.PulseValveOnce_bttn.Enable       = 'Off';
                app.PulseValveKx_bttn.Enable     = 'Off';
                drawnow;
            end 
        end
        
        % Mark: Arm and Disarm Stim Program
        function armStimProgram(app)
            app.dispAlert([0 0 0], 'Opening Stimulus Program...');          
            msg = app.stmCmd.openCommander;
            [msg2, info, failed]= app.stmCmd.waitForMessage(2);
                
            
            % Setup View list                    
            app.StimViews_list.Enable         = 'On';                    
            app.StimViews_list.Items          = {StimMessages.view_waitScreen,...
                                                 StimMessages.view_dotMovie,...
                                                 StimMessages.view_grayScreen,...
                                                 StimMessages.view_whiteScreen,...
                                                 StimMessages.shutDown};
            app.StimViews_list.Value =  app.StimViews_list.Items(1);
            
%             app.StimViews_list.                                             
            % Setup Coherence Spinner
            app.updateMocoParameterVals('coherence')
            app.SetCoherence_spnr.Enable = 'On';
                        
            % Setup LifeTime Spinner
            app.updateMocoParameterVals('lifetime')
            app.SetLifeTime_spnr.Enable = 'On';
            
            % Setup DotDirection Spinne and Button
            app.updateMocoParameterVals('lifetime')
            app.SetDotDirection_spnr.Enable = 'On';
            app.SetRandomDirection_btn.Enable = 'On'; 
            
            if app.stmCmd.madeContact
                app.log.write2DataFile({app.time.tElapsed, 'Stim', 'contactSuccessfull', nan}, DataLog.systemFile_extension) ;                                
                color = app.getFontColor(-1);
            else
                app.log.write2DataFile({app.time.tElapsed, 'Stim', 'contactFailed', nan}, DataLog.systemFile_extension)  ;                                           
                app.stmCmd.closeCommander;
%                 disableStimButtons(app) 
                color = app.getFontColor(1);
            end
            app.dispAlert(color, msg); 
            app.dispAlert(color, info); 
            
            app.StimArmed_lamp.Color = color;
        end
        
        function disarmStimProgram(app)
            if app.isvalid
                showView(app, StimMessages.shutDown);
                disableStimButtons(app)
                app.StimArmed_lamp.Color = [0 0 0];        
                app.dispAlert(app.getFontColor(0), 'Stim Viewer has shutdown'); 
                app.log.write2DataFile({app.time.tElapsed, 'Stim', 'shutdown', nan}, DataLog.systemFile_extension)  ;                           
            end
        end
        
        function disableStimButtons(app)
            app.StimViews_list.Enable = 'Off';
            app.SetCoherence_spnr.Enable = 'Off';
            app.SetLifeTime_spnr.Enable = 'Off';
            app.SetRandomDirection_btn.Enable = 'Off';
            app.SetDotDirection_spnr.Enable = 'Off';
            drawnow;                
        end         
        
        
        function showView(app, stimview)
            if ~any(contains(app.StimViews_list.Items, stimview ))
                set(app.StimViews_list, 'Value',  app.StimViews_list.Items(1));
            else
                set(app.StimViews_list, 'Value',  stimview);
            end
                app.select_StimViews_lst;  
            
            
        end
        
        function assignTags2PhaseSwitches(app)
            app.TrainPhase_Manual_swtch.Tag     = 'ManualPhase';     
            app.TrainPhase_FreeReward_swtch.Tag = 'FreeRewardPhase';
            app.TrainPhase_MustTurn_swtch.Tag   = 'MustTurnPhase';
            app.TrainPhase_FixedCoherence_swtch.Tag = 'FixedCoherencePhase';
            app.TrainPhase_VarCoherence_swtch.Tag   = 'VariedCoherencePhase';
        end
        
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            Devices.resetAllPorts(Devices)
            app.assignTags2PhaseSwitches(); 
        end

        % Value changed function: ulPerReward_editFld
        function change_ulPerReward(app, event)
            app.log.write2DataFile({app.time.tElapsed, 'Valve', 'ulAmountChange', app.ulPerReward_editFld.Value}, DataLog.systemFile_extension);      
            
        end

        % Close request function: UIFigure
        function closeRequest_UIFigure(app, event)
            delete(app);
        end

        % Button pushed function: PulseValveOnce_bttn
        function press_PulseValveOnce_btn(app, event)
            [msg, failed] = app.ard.triggerValve;
            app.dispAlert(app.getFontColor(.25*failed), msg)            
            app.log.write2DataFile({app.time.tElapsed, 'Valve', 'pulse', app.PulseWidth_spnr.Value}, DataLog.systemFile_extension);            
        end

        % Value changed function: PulseWidth_spnr
        function press_PulseWidth_spnr(app, event)
            if strcmp(app.ard.Mod.Status, 'open')
                value = app.PulseWidth_spnr.Value;
                app.ard.setPulseWidth(value);
                app.PulseWidth_spnr.Value       = app.ard.readPulseWidth;  
                app.dispAlert(app.getFontColor(0), 'PW updated')
            else
                app.dispAlert(app.getFontColor(.25), 'PW cannot be changed (Arduino not connected)')
            end
            app.log.write2DataFile({app.time.tElapsed, 'Valve', 'changedPulseWidth', app.PulseWidth_spnr.Value}, DataLog.systemFile_extension);            
            
        end

        % Value changed function: SetCoherence_spnr
        function press_SetCoherence_spnr(app, event)
            app.updateMocoParameterVals('coherence')
        end

        % Value changed function: SetDotDirection_spnr
        function press_SetDotDirection_spnr(app, event)
            app.updateMocoParameterVals('direction');
        end

        % Value changed function: SetLifeTime_spnr
        function press_SetLifeTime_spnr(app, event)
            app.updateMocoParameterVals('lifetime')
        end

        % Button pushed function: SetRandomDirection_btn
        function press_SetRandomDirection_btn(app, event)
            validDirections = [0 180]; 
            app.SetDotDirection_spnr.Value = validDirections(randi(2));
            app.updateMocoParameterVals('direction');
        end

        % Value changed function: TrainPhase_FixedCoherence_swtch
        function press_TrainPhase_FixedCoherence_swtch(app, event)
            if strcmp(app.TrainPhase_FixedCoherence_swtch.Value, 'End')
                app.phase.abort = 1;
            end      
                        
            if strcmp(app.TrainPhase_FixedCoherence_swtch.Value, 'Go')
                app.intitiatePhase;   
                
                logIt = @(data) app.log.write2DataFile(sprintf('%.03f %d %s %.01f\n', data{:}), DataLog.trialFile_extension );   
                timeOutDuration = 5;               
                trial = 0;                
                
                % Block 0: Lick To Start phase
                app.dispAlert([0 0 0], 'Will Start When Lick');
                while app.phase.keepTraining()
                    app.readBehavior;
                    if app.ard.sensorState == 1
                        logIt({app.time.tElapsed, trial, 'StartingPhase', nan});
                        block = 1;                          
                        break;
                    end
                end
                               
                while app.phase.keepTraining()  
            
                    if block == 1
                        % Give Reward   
                        press_PulseValveOnce_btn(app); 
                        logIt({app.time.tElapsed, trial, 'rewarded', app.ulPerReward_editFld.Value});
                        
                        % Show Gray Screen
                        showView(app, StimMessages.view_grayScreen)                         
                        logIt({app.time.tElapsed, trial, 'grayScreenON', nan});                                            
                        
                        % Wait For Consumption
                        app.dispAlert([0 0 0], 'Reward Given. Waiting for Consumption');
                        while app.phase.keepTraining()
                            app.readBehavior;
                            if app.ard.sensorState == 1
                                logIt({app.time.tElapsed, trial, 'consumed', nan});                         
                                break;
                            end
                        end
                        
                        % Wait Until stop licking                        
                        dispAlert(app, [0 0 0], 'Consumed Reward. Now Waiting to stop licking');
                        while app.phase.keepTraining()
                            app.readBehavior;
                            if app.ard.timeElapsedSinceLastTouch > .2
                                logIt({app.time.tElapsed, trial, 'stoppedLicking', nan});                   
                                break;
                            end
                        end  
                        
                        % Increment trial count 
                        trial = trial + 1;                        
                        logIt({app.time.tElapsed, trial, 'newTrial', nan});
                        
                        % Set Random dot direction  
                        press_SetRandomDirection_btn(app);                                                    
                        logIt({app.time.tElapsed, trial, 'newDotDir', app.SetDotDirection_spnr.Value});
                        
                        dispAlert(app, [0 0 0], 'New Trial & Random Dot Direction');                        
                        block = 2;
                    end                  
             
                    if block == 2
                        % Show Dots
                        showView(app, StimMessages.view_dotMovie);
                        logIt({app.time.tElapsed, trial, 'DotsON', nan});                                                
                        
                        % Zero Wheel
                        zeroWheel(app);                             
                        logIt({app.time.tElapsed, trial, 'wheelZerod', nan}) 
                        
                        % Wait for Wheel Turn
                        app.dispAlert([0 0 0], 'Zerod Wheel & Showing Dots. Now Waiting for Wheel Turn');                         
                        while app.phase.keepTraining()
                            app.readBehavior;
                            if abs(app.whl.currentPosition) > app.WheelTurnThreshold.Value
                                logIt({app.time.tElapsed, trial, 'wheelTurned', nan})
                                break;
                            end
                        end  
                        
                        if turnDirEqualsWheelDir(app)
                            % If Correct turn --> repeat block 1
                            logIt({app.time.tElapsed, trial, 'correctTurn', nan});                                                                            
                            app.dispAlert([0 0 0], 'Correct Wheel Turn!'); 
                            block = 1;
                        else
                            % If Wrong turn
                            logIt({app.time.tElapsed, trial, 'wrongTurn', nan});
                            
                            % Show White Screen
                            showView(app, StimMessages.view_whiteScreen) ;
                            logIt({app.time.tElapsed, trial, 'whiteScreenON', nan}); 
                            
                            % Time Out                          
                            app.dispAlert([0 0 0], 'Wrong Response.Time out (White Screen On)');                                          
                            tStart = tic;
                            while app.phase.keepTraining()  
                                app.readBehavior;
                                if toc(tStart) > timeOutDuration
                                    block = 2;
                                    break;
                                end
                            end                              
                        end   
            
                    end    
                end
                
            end
            
            if ~app.phase.keepTraining()
                app.finalizePhase;
            end
                        
        end

        % Value changed function: TrainPhase_FreeReward_swtch
        function press_TrainPhase_FreeReward_swtch(app, event)
            if strcmp(app.TrainPhase_FreeReward_swtch.Value, 'End')
                app.phase.abort = 1;
            end      
                        
            if strcmp(app.TrainPhase_FreeReward_swtch.Value, 'Go')
                app.intitiatePhase;                                   
                logIt = @(data) app.log.write2DataFile(sprintf('%.03f %d %s %.01f\n', data{:}), DataLog.trialFile_extension );   
                
                trial = 0;
                while app.phase.keepTraining()
                    % Increment trial count,                    
                    trial = trial + 1;   
                    logIt({app.time.tElapsed, trial, 'newTrial', trial}); 
                    
                    %  Wait For Lick
                    app.dispAlert([0 0 0], 'Waiting for Lick');
                    while app.phase.keepTraining()
                        app.readBehavior;
                        if app.ard.sensorState == 1
                            break;
                        end
                    end
                                        
                    % Give Reward    
                    press_PulseValveOnce_btn(app);                        
                    logIt({app.time.tElapsed, trial, 'rewarded', app.ulPerReward_editFld.Value}); 
                    
                    % Wait For Consumption                     
                    app.dispAlert([0 0 0], 'Reward Given. Waiting for Consumption');
                    while app.phase.keepTraining()
                        app.readBehavior;
                        if app.ard.sensorState == 1
                            logIt({app.time.tElapsed, trial, 'consumed', nan});                         
                            break;
                        end
                    end
                    
                    % Wait until stops licking                        
                    dispAlert(app, [0 0 0], 'Consumed Reward. Now Waiting to stop licking');
                    while app.phase.keepTraining()
                        app.readBehavior;
                        if app.ard.timeElapsedSinceLastTouch > .2
                            logIt({app.time.tElapsed, trial, 'stoppedLicking', nan});                   
                            break;
                        end
                    end    
                    
                end % repeat
            end
            
            if ~app.phase.keepTraining()
                app.finalizePhase;
            end
            
            
            
        end

        % Value changed function: TrainPhase_Manual_swtch
        function press_TrainPhase_Manual_swtch(app, event)
            if strcmp(app.TrainPhase_Manual_swtch.Value, 'End')
                app.phase.abort = 1;
            end            
            
            if strcmp(app.TrainPhase_Manual_swtch.Value, 'Go')
                app.intitiatePhase;    
                while app.phase.keepTraining()
                    app.readBehavior;                                                                                                         
                end
            end
            
            if ~app.phase.keepTraining()
                app.finalizePhase;
            end
                        
        end

        % Value changed function: TrainPhase_MustTurn_swtch
        function press_TrainPhase_MustTurn_swtch(app, event)
            if strcmp(app.TrainPhase_MustTurn_swtch.Value, 'End')
                app.phase.abort = 1;
            end      
                        
            if strcmp(app.TrainPhase_MustTurn_swtch.Value, 'Go')
                app.intitiatePhase;                                   
                logIt = @(data) app.log.write2DataFile(sprintf('%.03f %d %s %.01f\n', data{:}), DataLog.trialFile_extension );   
                
                % Lick To Start Phase
                trial = 0;                
                app.dispAlert([0 0 0], 'Will Start When Lick');
                while app.phase.keepTraining()
                    app.readBehavior
                    if app.ard.sensorState == 1
                        logIt({app.time.tElapsed, trial, 'StartingPhase', nan});
                        break;
                    end
                end                
                app.blcks.currentBlock = 1;                          
                
                while app.phase.keepTraining()  
                    % Give Reward
                    press_PulseValveOnce_btn(app);                        
                    logIt({app.time.tElapsed, trial, 'rewarded', app.ulPerReward_editFld.Value});  
                    
                    % Wait For Consumption                      
                    app.dispAlert([0 0 0], 'Reward Given. Waiting for Consumption');
                    while app.phase.keepTraining()
                        app.readBehavior;
                        if app.ard.sensorState == 1
                            logIt({app.time.tElapsed, trial, 'consumed', nan});                         
                            break;
                        end
                    end
                    
                    % Wait to stop licking                        
                    dispAlert(app, [0 0 0], 'Consumed Reward. Now Waiting to stop licking');
                    while app.phase.keepTraining()
                        app.readBehavior;
                        if app.ard.timeElapsedSinceLastTouch > .2
                            logIt({app.time.tElapsed, trial, 'stoppedLicking', nan});                   
                            break;
                        end
                    end  
                    
                    % Start new trial  
                    trial = trial + 1;                        
                    logIt({app.time.tElapsed, trial, 'newTrial', nan});
                    dispAlert(app, [0 0 0], 'New Trial');                        
                    
                    % Zero Wheel
                    zeroWheel(app);     
                    logIt({app.time.tElapsed, trial, 'wheelZerod', nan}) 
                    
                    % Wait until turns wheel
                    app.dispAlert([0 0 0], 'Zerod Wheel. Now Waiting for Wheel Turn');                         
                    while app.phase.keepTraining()
                        app.readBehavior;
                        if abs(app.whl.currentPosition) > app.WheelTurnThreshold.Value
                            logIt({app.time.tElapsed, trial, 'wheelTurned', nan})
                            break;
                        end
                    end    
                        
                    
                end % Repeat
                
            end
            
            if ~app.phase.keepTraining()
                app.finalizePhase;
            end
            
        end

        % Value changed function: StimViews_list
        function select_StimViews_lst(app, event)
            stimview = app.StimViews_list.Value;
            [msg, failed] = app.stmCmd.Write(stimview);
            if ~failed
                app.log.write2DataFile({app.time.tElapsed, 'Viewer', sprintf('Showing%s', stimview), nan}, DataLog.systemFile_extension);
            else
                app.log.write2DataFile({app.time.tElapsed, 'Viewer', sprintf('FailedToShow%s', stimview), []}, DataLog.systemFile_extension);                                                 
            end
            dispAlert(app, getFontColor(app, 1*failed), msg)
            
        end

        % Value changed function: WheelTurnThreshold
        function change_WheelTurnThreshold_spnr(app, event)
            value = app.WheelTurnThreshold.Value;
            app.WheelAxis.Children(2).XData = value*[1 1]; 
            app.WheelAxis.Children(3).XData = -value*[1 1]; 

        end

        % Button pushed function: PulseValveKx_bttn
        function press_PulseValveKx_btn(app, event)
            originalColor = app.PulseValveKx_bttn.BackgroundColor; 
            for i = 1:1000
                app.PulseValveKx_bttn.BackgroundColor = [.25 .25 1];  
                drawnow;
                
                [msg, failed] = app.ard.triggerValve;
                app.dispAlert(app.getFontColor(.25*failed), msg)            
                app.log.write2DataFile({app.time.tElapsed, 'Valve', 'pulse', app.PulseWidth_spnr.Value}, DataLog.systemFile_extension);      
                
                pause(.075);
                app.PulseValveKx_bttn.BackgroundColor = originalColor; 
                drawnow;
                pause(.075);
                
                if ~app.phase.keepTraining() 
                    break;
                end
                
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.8 0.8 0.8];
            app.UIFigure.Position = [100 100 871 569];
            app.UIFigure.Name = 'UI Figure';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @closeRequest_UIFigure, true);

            % Create RewardPanel_2
            app.RewardPanel_2 = uipanel(app.UIFigure);
            app.RewardPanel_2.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.RewardPanel_2.BorderType = 'none';
            app.RewardPanel_2.TitlePosition = 'centertop';
            app.RewardPanel_2.Title = 'Reward';
            app.RewardPanel_2.BackgroundColor = [1 1 1];
            app.RewardPanel_2.FontName = 'Microsoft JhengHei UI';
            app.RewardPanel_2.FontSize = 14;
            app.RewardPanel_2.Position = [21 251 157 199];

            % Create PulseValveOnce_bttn
            app.PulseValveOnce_bttn = uibutton(app.RewardPanel_2, 'push');
            app.PulseValveOnce_bttn.ButtonPushedFcn = createCallbackFcn(app, @press_PulseValveOnce_btn, true);
            app.PulseValveOnce_bttn.FontName = 'Microsoft JhengHei UI';
            app.PulseValveOnce_bttn.Enable = 'off';
            app.PulseValveOnce_bttn.Position = [34 16 43 25];
            app.PulseValveOnce_bttn.Text = '1x';

            % Create ulPulseLabel
            app.ulPulseLabel = uilabel(app.RewardPanel_2);
            app.ulPulseLabel.HorizontalAlignment = 'right';
            app.ulPulseLabel.VerticalAlignment = 'top';
            app.ulPulseLabel.FontName = 'Microsoft JhengHei UI';
            app.ulPulseLabel.Position = [40 148 51 15];
            app.ulPulseLabel.Text = 'ul/Pulse';

            % Create ulPerReward_editFld
            app.ulPerReward_editFld = uieditfield(app.RewardPanel_2, 'numeric');
            app.ulPerReward_editFld.Limits = [0 Inf];
            app.ulPerReward_editFld.ValueChangedFcn = createCallbackFcn(app, @change_ulPerReward, true);
            app.ulPerReward_editFld.HorizontalAlignment = 'center';
            app.ulPerReward_editFld.BackgroundColor = [0.9412 0.9412 0.9412];
            app.ulPerReward_editFld.Position = [106 144 21 22];
            app.ulPerReward_editFld.Value = 2;

            % Create PulseWidthmsLabel
            app.PulseWidthmsLabel = uilabel(app.RewardPanel_2);
            app.PulseWidthmsLabel.HorizontalAlignment = 'right';
            app.PulseWidthmsLabel.VerticalAlignment = 'top';
            app.PulseWidthmsLabel.FontName = 'Microsoft JhengHei UI';
            app.PulseWidthmsLabel.Position = [30 102 100 19];
            app.PulseWidthmsLabel.Text = 'Pulse Width (ms)';

            % Create PulseWidth_spnr
            app.PulseWidth_spnr = uispinner(app.RewardPanel_2);
            app.PulseWidth_spnr.Step = 5;
            app.PulseWidth_spnr.Limits = [0 Inf];
            app.PulseWidth_spnr.RoundFractionalValues = 'on';
            app.PulseWidth_spnr.ValueDisplayFormat = '%.0f';
            app.PulseWidth_spnr.ValueChangedFcn = createCallbackFcn(app, @press_PulseWidth_spnr, true);
            app.PulseWidth_spnr.Editable = 'off';
            app.PulseWidth_spnr.HorizontalAlignment = 'center';
            app.PulseWidth_spnr.Enable = 'off';
            app.PulseWidth_spnr.Position = [44 78 73 22];

            % Create PulseValveKx_bttn
            app.PulseValveKx_bttn = uibutton(app.RewardPanel_2, 'push');
            app.PulseValveKx_bttn.ButtonPushedFcn = createCallbackFcn(app, @press_PulseValveKx_btn, true);
            app.PulseValveKx_bttn.FontName = 'Microsoft JhengHei UI';
            app.PulseValveKx_bttn.Enable = 'off';
            app.PulseValveKx_bttn.Position = [81 16 42 25];
            app.PulseValveKx_bttn.Text = '1000x';

            % Create PulseLabel
            app.PulseLabel = uilabel(app.RewardPanel_2);
            app.PulseLabel.HorizontalAlignment = 'center';
            app.PulseLabel.FontName = 'Microsoft JhengHei UI';
            app.PulseLabel.Position = [50 44 63 15];
            app.PulseLabel.Text = 'Pulse';

            % Create StimulusPanel
            app.StimulusPanel = uipanel(app.UIFigure);
            app.StimulusPanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.StimulusPanel.BorderType = 'none';
            app.StimulusPanel.TitlePosition = 'centertop';
            app.StimulusPanel.Title = 'Stimulus';
            app.StimulusPanel.BackgroundColor = [1 1 1];
            app.StimulusPanel.FontName = 'Microsoft JhengHei UI';
            app.StimulusPanel.FontSize = 14;
            app.StimulusPanel.Position = [456 251 400 199];

            % Create ViewsListBoxLabel
            app.ViewsListBoxLabel = uilabel(app.StimulusPanel);
            app.ViewsListBoxLabel.HorizontalAlignment = 'center';
            app.ViewsListBoxLabel.FontName = 'Microsoft JhengHei UI';
            app.ViewsListBoxLabel.Position = [92 113 51 15];
            app.ViewsListBoxLabel.Text = 'Views';

            % Create StimViews_list
            app.StimViews_list = uilistbox(app.StimulusPanel);
            app.StimViews_list.Items = {'WaitScreen', 'Moco', 'WhiteScreen', 'GrayScreen'};
            app.StimViews_list.ValueChangedFcn = createCallbackFcn(app, @select_StimViews_lst, true);
            app.StimViews_list.Enable = 'off';
            app.StimViews_list.FontName = 'Microsoft JhengHei UI';
            app.StimViews_list.Position = [149 78 133 85];
            app.StimViews_list.Value = 'WaitScreen';

            % Create CoherenceLabel
            app.CoherenceLabel = uilabel(app.StimulusPanel);
            app.CoherenceLabel.VerticalAlignment = 'top';
            app.CoherenceLabel.FontName = 'Microsoft JhengHei UI';
            app.CoherenceLabel.Position = [24 44 88 15];
            app.CoherenceLabel.Text = 'Coherence (%)';

            % Create SetCoherence_spnr
            app.SetCoherence_spnr = uispinner(app.StimulusPanel);
            app.SetCoherence_spnr.Limits = [0 100];
            app.SetCoherence_spnr.RoundFractionalValues = 'on';
            app.SetCoherence_spnr.ValueDisplayFormat = '%.0f';
            app.SetCoherence_spnr.ValueChangedFcn = createCallbackFcn(app, @press_SetCoherence_spnr, true);
            app.SetCoherence_spnr.HorizontalAlignment = 'center';
            app.SetCoherence_spnr.FontName = 'Microsoft JhengHei UI';
            app.SetCoherence_spnr.Enable = 'off';
            app.SetCoherence_spnr.Position = [30 13 74 22];
            app.SetCoherence_spnr.Value = 60;

            % Create LifeTimeframesLabel
            app.LifeTimeframesLabel = uilabel(app.StimulusPanel);
            app.LifeTimeframesLabel.VerticalAlignment = 'top';
            app.LifeTimeframesLabel.FontName = 'Microsoft JhengHei UI';
            app.LifeTimeframesLabel.Position = [149 44 105 15];
            app.LifeTimeframesLabel.Text = 'Life Time (frames)';

            % Create SetLifeTime_spnr
            app.SetLifeTime_spnr = uispinner(app.StimulusPanel);
            app.SetLifeTime_spnr.Step = 5;
            app.SetLifeTime_spnr.Limits = [0 Inf];
            app.SetLifeTime_spnr.ValueDisplayFormat = '%.0f';
            app.SetLifeTime_spnr.ValueChangedFcn = createCallbackFcn(app, @press_SetLifeTime_spnr, true);
            app.SetLifeTime_spnr.HorizontalAlignment = 'center';
            app.SetLifeTime_spnr.FontName = 'Microsoft JhengHei UI';
            app.SetLifeTime_spnr.Enable = 'off';
            app.SetLifeTime_spnr.Position = [162 12 74 22];
            app.SetLifeTime_spnr.Value = 120;

            % Create DotDirectionSpinnerLabel
            app.DotDirectionSpinnerLabel = uilabel(app.StimulusPanel);
            app.DotDirectionSpinnerLabel.HorizontalAlignment = 'right';
            app.DotDirectionSpinnerLabel.VerticalAlignment = 'top';
            app.DotDirectionSpinnerLabel.FontName = 'Microsoft JhengHei UI';
            app.DotDirectionSpinnerLabel.Position = [298 43 81 15];
            app.DotDirectionSpinnerLabel.Text = 'Dot Direction';

            % Create SetDotDirection_spnr
            app.SetDotDirection_spnr = uispinner(app.StimulusPanel);
            app.SetDotDirection_spnr.Step = 180;
            app.SetDotDirection_spnr.Limits = [0 180];
            app.SetDotDirection_spnr.RoundFractionalValues = 'on';
            app.SetDotDirection_spnr.ValueDisplayFormat = '%.0f';
            app.SetDotDirection_spnr.ValueChangedFcn = createCallbackFcn(app, @press_SetDotDirection_spnr, true);
            app.SetDotDirection_spnr.HorizontalAlignment = 'center';
            app.SetDotDirection_spnr.Enable = 'off';
            app.SetDotDirection_spnr.Position = [285 11 62 22];

            % Create SetRandomDirection_btn
            app.SetRandomDirection_btn = uibutton(app.StimulusPanel, 'push');
            app.SetRandomDirection_btn.ButtonPushedFcn = createCallbackFcn(app, @press_SetRandomDirection_btn, true);
            app.SetRandomDirection_btn.FontName = 'Microsoft JhengHei UI';
            app.SetRandomDirection_btn.Enable = 'off';
            app.SetRandomDirection_btn.Position = [356 11 42 22];
            app.SetRandomDirection_btn.Text = '?';

            % Create NotificationsPanel
            app.NotificationsPanel = uipanel(app.UIFigure);
            app.NotificationsPanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.NotificationsPanel.BackgroundColor = [1 1 1];
            app.NotificationsPanel.Position = [21 460 558 97];

            % Create Notifications_lbl
            app.Notifications_lbl = uilabel(app.NotificationsPanel);
            app.Notifications_lbl.HorizontalAlignment = 'center';
            app.Notifications_lbl.FontName = 'Microsoft JhengHei UI';
            app.Notifications_lbl.FontSize = 14;
            app.Notifications_lbl.Position = [20 39 56 18];
            app.Notifications_lbl.Text = 'Notices';

            % Create NotificationCenter_1
            app.NotificationCenter_1 = uilabel(app.NotificationsPanel);
            app.NotificationCenter_1.BackgroundColor = [0.9412 0.9412 0.9412];
            app.NotificationCenter_1.FontName = 'Microsoft JhengHei UI';
            app.NotificationCenter_1.FontSize = 10;
            app.NotificationCenter_1.Position = [90 74 456 20];
            app.NotificationCenter_1.Text = '';

            % Create NotificationCenter_2
            app.NotificationCenter_2 = uilabel(app.NotificationsPanel);
            app.NotificationCenter_2.BackgroundColor = [0.9412 0.9412 0.9412];
            app.NotificationCenter_2.FontName = 'Microsoft JhengHei UI';
            app.NotificationCenter_2.FontSize = 10;
            app.NotificationCenter_2.Position = [90 51 456 20];
            app.NotificationCenter_2.Text = '';

            % Create NotificationCenter_3
            app.NotificationCenter_3 = uilabel(app.NotificationsPanel);
            app.NotificationCenter_3.BackgroundColor = [0.9412 0.9412 0.9412];
            app.NotificationCenter_3.FontName = 'Microsoft JhengHei UI';
            app.NotificationCenter_3.FontSize = 10;
            app.NotificationCenter_3.Position = [90 27 456 20];
            app.NotificationCenter_3.Text = '';

            % Create NotificationCenter_4
            app.NotificationCenter_4 = uilabel(app.NotificationsPanel);
            app.NotificationCenter_4.BackgroundColor = [0.9412 0.9412 0.9412];
            app.NotificationCenter_4.FontName = 'Microsoft JhengHei UI';
            app.NotificationCenter_4.FontSize = 10;
            app.NotificationCenter_4.Position = [90 4 456 20];
            app.NotificationCenter_4.Text = '';

            % Create WheelSensorPanel
            app.WheelSensorPanel = uipanel(app.UIFigure);
            app.WheelSensorPanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.WheelSensorPanel.BorderType = 'none';
            app.WheelSensorPanel.TitlePosition = 'centertop';
            app.WheelSensorPanel.Title = 'Wheel & Sensor';
            app.WheelSensorPanel.BackgroundColor = [1 1 1];
            app.WheelSensorPanel.FontName = 'Microsoft JhengHei UI';
            app.WheelSensorPanel.FontSize = 14;
            app.WheelSensorPanel.Position = [201 251 233 199];

            % Create WheelAxis
            app.WheelAxis = uiaxes(app.WheelSensorPanel);
            app.WheelAxis.Toolbar.Visible = 'off';
            app.WheelAxis.CameraPosition = [0 0 9.16025403784439];
            app.WheelAxis.CameraTarget = [0 0 0.5];
            app.WheelAxis.CameraUpVectorMode = 'manual';
            app.WheelAxis.DataAspectRatio = [360 2 1];
            app.WheelAxis.PlotBoxAspectRatio = [1 1 1];
            app.WheelAxis.XLim = [-180 180];
            app.WheelAxis.YLim = [-1 1];
            app.WheelAxis.ZLimMode = 'manual';
            app.WheelAxis.CLimMode = 'manual';
            app.WheelAxis.XColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.WheelAxis.XTick = [-180 -90 0 90 180];
            app.WheelAxis.XTickLabelRotationMode = 'manual';
            app.WheelAxis.YColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.WheelAxis.YTick = [-1 -0.5 0 0.5 1];
            app.WheelAxis.YTickLabelRotationMode = 'manual';
            app.WheelAxis.YTickLabel = '';
            app.WheelAxis.ZColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.WheelAxis.ZTickMode = 'manual';
            app.WheelAxis.BoxStyle = 'full';
            app.WheelAxis.LineWidth = 1;
            app.WheelAxis.Color = [1 1 1];
            app.WheelAxis.GridColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.WheelAxis.MinorGridColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.WheelAxis.GridAlpha = 0.15;
            app.WheelAxis.MinorGridAlphaMode = 'manual';
            app.WheelAxis.Box = 'on';
            app.WheelAxis.ColorOrder = [0.066 0.443 0.745;0.866 0.329 0;0.929 0.694 0.125;0.521 0.086 0.819;0.231 0.666 0.196;0.184 0.745 0.937;0.819 0.015 0.545];
            app.WheelAxis.Position = [14 57 208 63];

            % Create TurnThresholdLabel
            app.TurnThresholdLabel = uilabel(app.WheelSensorPanel);
            app.TurnThresholdLabel.HorizontalAlignment = 'right';
            app.TurnThresholdLabel.VerticalAlignment = 'top';
            app.TurnThresholdLabel.FontName = 'Microsoft JhengHei UI';
            app.TurnThresholdLabel.Position = [17 148 95 15];
            app.TurnThresholdLabel.Text = 'Turn Threshold';

            % Create WheelTurnThreshold
            app.WheelTurnThreshold = uispinner(app.WheelSensorPanel);
            app.WheelTurnThreshold.Step = 5;
            app.WheelTurnThreshold.Limits = [1 Inf];
            app.WheelTurnThreshold.RoundFractionalValues = 'on';
            app.WheelTurnThreshold.ValueDisplayFormat = '%.0f';
            app.WheelTurnThreshold.ValueChangedFcn = createCallbackFcn(app, @change_WheelTurnThreshold_spnr, true);
            app.WheelTurnThreshold.Editable = 'off';
            app.WheelTurnThreshold.HorizontalAlignment = 'center';
            app.WheelTurnThreshold.Position = [137 141 73 22];
            app.WheelTurnThreshold.Value = 45;

            % Create SensorState_lamp
            app.SensorState_lamp = uilamp(app.WheelSensorPanel);
            app.SensorState_lamp.Position = [137 15 25 25];
            app.SensorState_lamp.Color = [0.149 0.149 0.149];

            % Create LickLabel
            app.LickLabel = uilabel(app.WheelSensorPanel);
            app.LickLabel.HorizontalAlignment = 'right';
            app.LickLabel.VerticalAlignment = 'top';
            app.LickLabel.FontName = 'Microsoft JhengHei UI';
            app.LickLabel.Position = [95 20 27 15];
            app.LickLabel.Text = 'Lick';

            % Create PhasesPanel
            app.PhasesPanel = uipanel(app.UIFigure);
            app.PhasesPanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.PhasesPanel.BorderType = 'none';
            app.PhasesPanel.TitlePosition = 'centertop';
            app.PhasesPanel.Title = 'Phases';
            app.PhasesPanel.BackgroundColor = [1 1 1];
            app.PhasesPanel.FontName = 'Microsoft JhengHei UI';
            app.PhasesPanel.FontSize = 14;
            app.PhasesPanel.Position = [24 7 832 232];

            % Create TrainingPhase_tabgrp
            app.TrainingPhase_tabgrp = uitabgroup(app.PhasesPanel);
            app.TrainingPhase_tabgrp.Position = [19 30 627 157];

            % Create PhasesTab
            app.PhasesTab = uitab(app.TrainingPhase_tabgrp);
            app.PhasesTab.Title = 'Phases';
            app.PhasesTab.BackgroundColor = [1 1 1];
            app.PhasesTab.ForegroundColor = [0.149 0.149 0.149];

            % Create FreeRewardLabel
            app.FreeRewardLabel = uilabel(app.PhasesTab);
            app.FreeRewardLabel.HorizontalAlignment = 'center';
            app.FreeRewardLabel.VerticalAlignment = 'top';
            app.FreeRewardLabel.Position = [130 9 73 15];
            app.FreeRewardLabel.Text = 'Free Reward';

            % Create TrainPhase_FreeReward_swtch
            app.TrainPhase_FreeReward_swtch = uiswitch(app.PhasesTab, 'toggle');
            app.TrainPhase_FreeReward_swtch.Items = {'End', 'Go'};
            app.TrainPhase_FreeReward_swtch.ValueChangedFcn = createCallbackFcn(app, @press_TrainPhase_FreeReward_swtch, true);
            app.TrainPhase_FreeReward_swtch.Position = [156 60 20 45];
            app.TrainPhase_FreeReward_swtch.Value = 'End';

            % Create MustTurnSwitchLabel
            app.MustTurnSwitchLabel = uilabel(app.PhasesTab);
            app.MustTurnSwitchLabel.HorizontalAlignment = 'center';
            app.MustTurnSwitchLabel.VerticalAlignment = 'top';
            app.MustTurnSwitchLabel.FontColor = [0.149 0.149 0.149];
            app.MustTurnSwitchLabel.Position = [253 9 59 15];
            app.MustTurnSwitchLabel.Text = 'Must Turn';

            % Create TrainPhase_MustTurn_swtch
            app.TrainPhase_MustTurn_swtch = uiswitch(app.PhasesTab, 'toggle');
            app.TrainPhase_MustTurn_swtch.Items = {'End', 'Go'};
            app.TrainPhase_MustTurn_swtch.ValueChangedFcn = createCallbackFcn(app, @press_TrainPhase_MustTurn_swtch, true);
            app.TrainPhase_MustTurn_swtch.FontColor = [0.149 0.149 0.149];
            app.TrainPhase_MustTurn_swtch.Position = [272 60 20 45];
            app.TrainPhase_MustTurn_swtch.Value = 'End';

            % Create FixedCoherenceLabel
            app.FixedCoherenceLabel = uilabel(app.PhasesTab);
            app.FixedCoherenceLabel.HorizontalAlignment = 'center';
            app.FixedCoherenceLabel.VerticalAlignment = 'top';
            app.FixedCoherenceLabel.Position = [358 9 97 15];
            app.FixedCoherenceLabel.Text = 'Fixed Coherence';

            % Create TrainPhase_FixedCoherence_swtch
            app.TrainPhase_FixedCoherence_swtch = uiswitch(app.PhasesTab, 'toggle');
            app.TrainPhase_FixedCoherence_swtch.Items = {'End', 'Go'};
            app.TrainPhase_FixedCoherence_swtch.ValueChangedFcn = createCallbackFcn(app, @press_TrainPhase_FixedCoherence_swtch, true);
            app.TrainPhase_FixedCoherence_swtch.Position = [395 60 20 45];
            app.TrainPhase_FixedCoherence_swtch.Value = 'End';

            % Create VariedCoherenceLabel_2
            app.VariedCoherenceLabel_2 = uilabel(app.PhasesTab);
            app.VariedCoherenceLabel_2.HorizontalAlignment = 'center';
            app.VariedCoherenceLabel_2.VerticalAlignment = 'top';
            app.VariedCoherenceLabel_2.FontColor = [1 0 0];
            app.VariedCoherenceLabel_2.Position = [496 9 101 15];
            app.VariedCoherenceLabel_2.Text = 'Varied Coherence';

            % Create TrainPhase_VarCoherence_swtch
            app.TrainPhase_VarCoherence_swtch = uiswitch(app.PhasesTab, 'toggle');
            app.TrainPhase_VarCoherence_swtch.Items = {'End', 'Go'};
            app.TrainPhase_VarCoherence_swtch.FontColor = [1 0 0];
            app.TrainPhase_VarCoherence_swtch.Position = [536 60 20 45];
            app.TrainPhase_VarCoherence_swtch.Value = 'End';

            % Create ManualLabel
            app.ManualLabel = uilabel(app.PhasesTab);
            app.ManualLabel.HorizontalAlignment = 'center';
            app.ManualLabel.VerticalAlignment = 'top';
            app.ManualLabel.Position = [28 9 45 15];
            app.ManualLabel.Text = 'Manual';

            % Create TrainPhase_Manual_swtch
            app.TrainPhase_Manual_swtch = uiswitch(app.PhasesTab, 'toggle');
            app.TrainPhase_Manual_swtch.Items = {'End', 'Go'};
            app.TrainPhase_Manual_swtch.ValueChangedFcn = createCallbackFcn(app, @press_TrainPhase_Manual_swtch, true);
            app.TrainPhase_Manual_swtch.Position = [40 60 20 45];
            app.TrainPhase_Manual_swtch.Value = 'End';

            % Create Panel_3
            app.Panel_3 = uipanel(app.PhasesPanel);
            app.Panel_3.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.Panel_3.TitlePosition = 'centertop';
            app.Panel_3.BackgroundColor = [1 1 1];
            app.Panel_3.Position = [670 30 142 105];

            % Create MouseIDLabel
            app.MouseIDLabel = uilabel(app.Panel_3);
            app.MouseIDLabel.HorizontalAlignment = 'right';
            app.MouseIDLabel.VerticalAlignment = 'top';
            app.MouseIDLabel.FontName = 'Microsoft JhengHei UI';
            app.MouseIDLabel.Position = [39 81 60 15];
            app.MouseIDLabel.Text = 'Mouse ID';

            % Create MouseID_txtfld
            app.MouseID_txtfld = uieditfield(app.Panel_3, 'text');
            app.MouseID_txtfld.HorizontalAlignment = 'center';
            app.MouseID_txtfld.Position = [36 53 71 22];

            % Create LogInProgress_lbl
            app.LogInProgress_lbl = uilabel(app.Panel_3);
            app.LogInProgress_lbl.HorizontalAlignment = 'center';
            app.LogInProgress_lbl.FontSize = 10;
            app.LogInProgress_lbl.Position = [13 19 118 15];
            app.LogInProgress_lbl.Text = '';

            % Create Panel_4
            app.Panel_4 = uipanel(app.PhasesPanel);
            app.Panel_4.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.Panel_4.TitlePosition = 'centertop';
            app.Panel_4.BackgroundColor = [1 1 1];
            app.Panel_4.Position = [670 150 142 37];

            % Create timeElapsed_lbl
            app.timeElapsed_lbl = uilabel(app.Panel_4);
            app.timeElapsed_lbl.HorizontalAlignment = 'center';
            app.timeElapsed_lbl.Position = [90 12 42 15];
            app.timeElapsed_lbl.Text = '0';

            % Create ElapsedtimeLabel
            app.ElapsedtimeLabel = uilabel(app.Panel_4);
            app.ElapsedtimeLabel.VerticalAlignment = 'top';
            app.ElapsedtimeLabel.FontName = 'Microsoft JhengHei UI';
            app.ElapsedtimeLabel.Position = [9 12 77 15];
            app.ElapsedtimeLabel.Text = 'Elapsed time';

            % Create DevicesPanel
            app.DevicesPanel = uipanel(app.UIFigure);
            app.DevicesPanel.ForegroundColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.DevicesPanel.TitlePosition = 'centertop';
            app.DevicesPanel.Title = 'Devices';
            app.DevicesPanel.BackgroundColor = [1 1 1];
            app.DevicesPanel.FontName = 'Microsoft YaHei UI';
            app.DevicesPanel.Position = [597 460 259 97];

            % Create ArmDevices_swtch
            app.ArmDevices_swtch = uiswitch(app.DevicesPanel, 'slider');
            app.ArmDevices_swtch.Items = {'Off', 'Arm'};
            app.ArmDevices_swtch.Enable = 'off';
            app.ArmDevices_swtch.FontName = 'Microsoft JhengHei UI';
            app.ArmDevices_swtch.Position = [41 29 47 21];

            % Create ArduinoLampLabel
            app.ArduinoLampLabel = uilabel(app.DevicesPanel);
            app.ArduinoLampLabel.HorizontalAlignment = 'right';
            app.ArduinoLampLabel.VerticalAlignment = 'top';
            app.ArduinoLampLabel.FontName = 'Microsoft JhengHei UI';
            app.ArduinoLampLabel.Position = [139 50 51 15];
            app.ArduinoLampLabel.Text = 'Arduino';

            % Create ArduinoArmed_lamp
            app.ArduinoArmed_lamp = uilamp(app.DevicesPanel);
            app.ArduinoArmed_lamp.Position = [205 53 10 10];
            app.ArduinoArmed_lamp.Color = [0 0 0];

            % Create WheelLampLabel
            app.WheelLampLabel = uilabel(app.DevicesPanel);
            app.WheelLampLabel.HorizontalAlignment = 'right';
            app.WheelLampLabel.VerticalAlignment = 'top';
            app.WheelLampLabel.FontName = 'Microsoft JhengHei UI';
            app.WheelLampLabel.Position = [149 32 41 15];
            app.WheelLampLabel.Text = 'Wheel';

            % Create WheelArmed_lamp
            app.WheelArmed_lamp = uilamp(app.DevicesPanel);
            app.WheelArmed_lamp.Position = [205 35 10 10];
            app.WheelArmed_lamp.Color = [0 0 0];

            % Create StimulusLabel
            app.StimulusLabel = uilabel(app.DevicesPanel);
            app.StimulusLabel.HorizontalAlignment = 'right';
            app.StimulusLabel.VerticalAlignment = 'top';
            app.StimulusLabel.FontName = 'Microsoft JhengHei UI';
            app.StimulusLabel.Position = [136 15 54 15];
            app.StimulusLabel.Text = 'Stimulus';

            % Create StimArmed_lamp
            app.StimArmed_lamp = uilamp(app.DevicesPanel);
            app.StimArmed_lamp.Position = [205 18 10 10];
            app.StimArmed_lamp.Color = [0 0 0];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Moco_r2017b_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
