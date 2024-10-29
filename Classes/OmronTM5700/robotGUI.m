classdef robotGUI < handle
    properties
        fig           % Main GUI figure
        slidersOmron  % Array of sliders for Omron robot control
        slidersWelder % Array of sliders for Welder robot control
        robotOmron    % Omron robot model
        robotWelder   % Welder robot model
        qOmron        % Joint configuration for Omron robot
        qWelder       % Joint configuration for Welder robot
        eStopEnabled  % Tracks if EStop is enabled
        resumeButton  % Resume button
        eStopButton   % EStop button
    end
    
    methods
        function app = robotGUI()
            % Initialize the OmronTM5700
                oBaseTr = transl(0,0,0.5);
                                                  % Plots steel plate (Case 2)
            % Initialize the welderRS Robot
                wBaseTr = transl(0.3,0,0.5);
            % Initialize the robots
            app.robotOmron = OmronTM5700(oBaseTr,2);  % Replace with your Omron robot model
            app.robotWelder = WelderRobot(wBaseTr); % Replace with your Welder robot model
            app.qOmron = zeros(1, app.robotOmron.model.n); % Initialize joint angles for Omron
            app.qWelder = zeros(1, app.robotWelder.model.n); % Initialize joint angles for Welder
            app.eStopEnabled = false; % Initially, EStop is not enabled

            % Create GUI
            app.createGUI();
            
            % Set initial robot positions in the existing environment
            app.robotOmron.model.animate(app.qOmron);
            app.robotWelder.model.animate(app.qWelder);
        end
        
        function createGUI(app)
            % Create the main figure window
            app.fig = uifigure('Name', 'Robot GUI', 'Position', [100, 100, 800, 600]);
            
            % Define slider limits based on joint limits for each robot
            jointLimitsOmron = app.robotOmron.model.qlim;
            jointLimitsWelder = app.robotWelder.model.qlim;
            
            % Create sliders for each joint in Omron robot
            numJointsOmron = app.robotOmron.model.n;
            app.slidersOmron = gobjects(1, numJointsOmron); % Preallocate slider array
            
            for i = 1:numJointsOmron
                % Label for each Omron joint
                uilabel(app.fig, 'Text', sprintf('Omron Joint %d', i), ...
                    'Position', [20, 600 - 60*i, 100, 22]);
                
                % Ensure joint limits are valid for Omron
                if ~isfinite(jointLimitsOmron(i, 1)) || ~isfinite(jointLimitsOmron(i, 2)) || jointLimitsOmron(i, 1) >= jointLimitsOmron(i, 2)
                    jointLimitsOmron(i, :) = [-pi, pi]; % Default limits if invalid
                end
                
                % Slider for each Omron joint with jog functionality
                app.slidersOmron(i) = uislider(app.fig, ...
                    'Limits', jointLimitsOmron(i, :), ...
                    'Value', app.qOmron(i), ...
                    'Position', [130, 600 - 60*i, 250, 3], ...
                    'ValueChangingFcn', @(src, event)app.jogJointOmron(i, event.Value));
            end
            
            % Create sliders for each joint in Welder robot
            numJointsWelder = app.robotWelder.model.n;
            app.slidersWelder = gobjects(1, numJointsWelder); % Preallocate slider array
            
            for i = 1:numJointsWelder
                % Label for each Welder joint
                uilabel(app.fig, 'Text', sprintf('Welder Joint %d', i), ...
                    'Position', [420, 600 - 60*i, 100, 22]);
                
                % Ensure joint limits are valid for Welder
                if ~isfinite(jointLimitsWelder(i, 1)) || ~isfinite(jointLimitsWelder(i, 2)) || jointLimitsWelder(i, 1) >= jointLimitsWelder(i, 2)
                    jointLimitsWelder(i, :) = [-pi, pi]; % Default limits if invalid
                end
                
                % Slider for each Welder joint with jog functionality
                app.slidersWelder(i) = uislider(app.fig, ...
                    'Limits', jointLimitsWelder(i, :), ...
                    'Value', app.qWelder(i), ...
                    'Position', [530, 600 - 60*i, 250, 3], ...
                    'ValueChangingFcn', @(src, event)app.jogJointWelder(i, event.Value));
            end

            % Create EStop button
            app.eStopButton = uibutton(app.fig, 'push', 'Text', 'EStop', ...
                'Position', [20, 50, 100, 40], ...
                'ButtonPushedFcn', @(~, ~)app.eStop());

            % Create Resume button
            app.resumeButton = uibutton(app.fig, 'push', 'Text', 'Resume', ...
                'Position', [140, 50, 100, 40], ...
                'ButtonPushedFcn', @(~, ~)app.resume(), ...
                'Enable', 'off'); % Initially disabled        
        end
        
        function jogJointOmron(app, jointIndex, value)
            % Update the specific Omron joint angle while the slider is moving
            if ~app.eStopEnabled
                app.qOmron(jointIndex) = value;
                app.robotOmron.model.animate(app.qOmron);  % Animate robot directly
            end
        end
        
        function jogJointWelder(app, jointIndex, value)
            % Update the specific Welder joint angle while the slider is moving
            if ~app.eStopEnabled
                app.qWelder(jointIndex) = value;
                app.robotWelder.model.animate(app.qWelder); % Animate robot directly
            end
        end
    
        function eStop(app)
            % Emergency Stop function: disable all sliders and stop robots
            app.eStopEnabled = true;
            app.enableSliders(false); % Disable sliders
            app.eStopButton.Enable = 'off'; % Disable EStop button
            app.resumeButton.Enable = 'on'; % Enable Resume button
        end

        function resume(app)
            % Resume function: re-enable all sliders to allow robot jogging
            app.eStopEnabled = false;
            app.enableSliders(true); % Enable sliders
            app.eStopButton.Enable = 'on'; % Enable EStop button
            app.resumeButton.Enable = 'off'; % Disable Resume button
        end
        
        function enableSliders(app, enable)
            % Helper function to enable or disable sliders based on EStop status
            sliderState = 'off';
            if enable
                sliderState = 'on';
            end
            % Set state for all Omron and Welder sliders
            for i = 1:numel(app.slidersOmron)
                app.slidersOmron(i).Enable = sliderState;
            end
            for i = 1:numel(app.slidersWelder)
                app.slidersWelder(i).Enable = sliderState;
            end
        end
    end
end
