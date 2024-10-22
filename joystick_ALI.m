%% Joy-Con
id = 1; 

joy = vrjoystick(id);
joy_info = caps(joy); 

fprintf('Your Joy-Con has:\n');
fprintf(' - %i buttons\n', joy_info.Buttons);
fprintf(' - %i axes\n', joy_info.Axes);
pause(2);

% Continuously read inputs
while(1)
    
    % Attempt to read Joy-Con buttons and axes
    try
        [axes, buttons, povs] = read(joy);
        
        % Print buttons and axes info
        str = sprintf('--------------\n');
        for i = 1:joy_info.Buttons
            str = [str sprintf('Button[%i]:%i\n',i,buttons(i))];
        end
        for i = 1:joy_info.Axes 
            str = [str sprintf('Axes[%i]:%1.3f\n',i,axes(i))];
        end
        str = [str sprintf('--------------\n')];
        fprintf('%s',str);
        pause(0.05);  
        
    catch
        fprintf('Error reading data. Please check the Joy-Con connection.\n');
    end
    
end
