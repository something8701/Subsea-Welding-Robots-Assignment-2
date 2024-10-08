joy = vrjoystick(1);

while true
    % Get the axis values and button presses
    axesValues = axis(joy);
    buttons = button(joy);

    % Display axis movements
    disp(['Axes values: ', num2str(axesValues)]);
    
    % Display button presses
    disp(['Buttons pressed: ', num2str(buttons)]);
    
    % Check if a button is being pressed when you move the joystick
    if any(buttons)
        disp('Button pressed.');
    end
    
    pause(1);  % Pause for a short time before next check
end

