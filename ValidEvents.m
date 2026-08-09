classdef ValidEvents < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    % Valid Objects
    properties 
       arduino
       wheel
       stim
       mouse
       valve
       
    end
    
    methods
        function  VaildEvents(obj)
            obj.arduino.arduino_contact_failure   = 'ArduinoMadeContact';
            
            obj.valve.name              = 'Valve';            
            obj.valve.PWchanged         = 'PulseWidthChanged';
            obj.valve.ulPerPulseChanged = 'ulAmount_per_pulse_changed';
            
            obj.wheel.name               = 'Wheel';
            obj.wheel.contactSuccess    = 'contactSUCCESS';
            obj.wheel.contactFailed     = 'contactFAILED';
            obj.wheel.useKeyBoard       = 'useKeyBoard';
            obj.wheel.zerod             = 'positionZerod';
            obj.wheel.turnThreshChanged = 'turnThresholdChanged';
            
            obj.stim.name                       = 'StimCommander';
            obj.stim.contactWithViewerSuccess   = 'SUCCESS_ContactWithViewer';
            obj.stim.contactWithViewerFailure   = 'FAILED_ContactWithViewer';
            obj.stim.showingView                = 'showingView';
            
            obj.mouse.name                      = 'Mouse';
            obj.mouse.touchedSensor             = 'touchedSensor';
            obj.mouse.consumedReward            = 'consumedReward';
            obj.mouse.turnedWheel               = 'turnedWheel';
            
        end
        
    end
    
    
    
    methods
        function obj = untitled2(inputArg1,inputArg2)
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

