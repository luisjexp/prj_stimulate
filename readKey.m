function keyCmd = readKey
        keyCmd = '';
        [keyIsDown, ~, keyCode] = KbCheck();
        if keyIsDown
            keyCmd = KbName(find(keyCode));
        end
        
        if iscell(keyCmd)
           keyCmd = keyCmd{1}; % if user presses 2 buttons, only return 1 (errors pop up otherwise)
        end
               
        if keyIsDown
           fprintf('\t[%s] pressed   ', keyCmd)
        end
end

