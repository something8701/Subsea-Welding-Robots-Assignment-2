classdef robotGUI < handle
    properties
        fig             % Main GUI figure
        slidersOmron    % Array of sliders for Omron robot control
        slidersWelder   % Array of sliders for Welder robot control
        robotOmron      % Omron robot model
        robotWelder     % Welder robot model
        qOmron          % Joint configuration for Omron robot
        qWelder         % Joint configuration for Welder robot
        eStopEnabled    % Tracks if EStop is enabled
        resumeButton    % Resume button
        eStopButton     % EStop button
        poseTextArea    % Text area to display joint positions
    end
    
    methods
        function app = robotGUI()
            global eStopEnabled;
            eStopEnabled = false;

            % Initialize robots (comment out SteelPlate if it's non-essential)
            oBaseTr = transl(0,0,0.5);      
            wBaseTr = transl(0.3,0,0.5);
            app.robotOmron = OmronTM5700(oBaseTr,2);  
            app.robotWelder = WelderRobot(wBaseTr);   
            app.qOmron = zeros(1, app.robotOmron.model.n); 
            app.qWelder = zeros(1, app.robotWelder.model.n);

            % Create GUI
            app.createGUI();
            
            % Set initial robot positions
            app.robotOmron.model.animate(app.qOmron);
            app.robotWelder.model.animate(app.qWelder);
            app.updatePoseDisplay(); % Initialize pose display
        end
        
        function createGUI(app)
            % Main figure window
            app.fig = uifigure('Name', 'Robot GUI', 'Position', [100, 100, 900, 600]);

            % Define joint limits with defaults if undefined
                jointLimitsOmron = app.getJointLimits(app.robotOmron.model.qlim, app.robotOmron.model.n);
                jointLimitsWelder = app.getJointLimits(app.robotWelder.model.qlim, app.robotWelder.model.n);

            % Create sliders for Omron joints
            numJointsOmron = app.robotOmron.model.n;
            app.slidersOmron = gobjects(1, numJointsOmron);
            for i = 1:numJointsOmron
                uilabel(app.fig, 'Text', sprintf('Omron Joint %d (rad)', i), ...
                    'Position', [20, 600 - 60*i, 100, 22]);
                
                app.slidersOmron(i) = uislider(app.fig, ...
                    'Limits', jointLimitsOmron(i, :), ...
                    'Value', app.qOmron(i), ...
                    'Position', [130, 600 - 60*i, 250, 3], ...
                    'ValueChangingFcn', @(src, event)app.jogJointOmron(i, event.Value));
            end
            
            % Create sliders for Welder joints
            numJointsWelder = app.robotWelder.model.n;
            app.slidersWelder = gobjects(1, numJointsWelder);
            for i = 1:numJointsWelder
                uilabel(app.fig, 'Text', sprintf('Welder Joint %d (rad)', i), ...
                    'Position', [420, 600 - 60*i, 100, 22]);
                
                app.slidersWelder(i) = uislider(app.fig, ...
                    'Limits', jointLimitsWelder(i, :), ...
                    'Value', app.qWelder(i), ...
                    'Position', [530, 600 - 60*i, 250, 3], ...
                    'ValueChangingFcn', @(src, event)app.jogJointWelder(i, event.Value));
            end

            % EStop and Resume buttons
            app.eStopButton = uibutton(app.fig, 'push', 'Text', 'EStop', ...
                'Position', [20, 50, 100, 40], ...
                'ButtonPushedFcn', @(~, ~)app.eStop());
            app.resumeButton = uibutton(app.fig, 'push', 'Text', 'Resume', ...
                'Position', [140, 50, 100, 40], ...
                'ButtonPushedFcn', @(~, ~)app.resume(), ...
                'Enable', 'off'); % Initially disabled 

            % Text area for real-time pose display
            app.poseTextArea = uitextarea(app.fig, 'Position', [800, 150, 150, 300], ...
                'Editable', 'off', 'Value', {'Robot Pose Info'});
        end
        
        function jointLimits = getJointLimits(~, qlim, numJoints)
            % Helper to return valid joint limits or default to [-pi, pi]
            jointLimits = repmat([-pi, pi], numJoints, 1);  % Default limits
            for i = 1:numJoints
                if size(qlim, 2) == 2 && all(isfinite(qlim(i, :))) && qlim(i, 1) < qlim(i, 2)
                    jointLimits(i, :) = qlim(i, :);  % Use defined limits if valid
                end
            end
        end
        
        function jogJointOmron(app, jointIndex, value)
            % Update Omron joint angle and pose display
            app.qOmron(jointIndex) = value;
            app.robotOmron.model.animate(app.qOmron);  
            app.updatePoseDisplay();
        end
        
        function jogJointWelder(app, jointIndex, value)
            % Update Welder joint angle and pose display
            app.qWelder(jointIndex) = value;
            app.robotWelder.model.animate(app.qWelder);  
            app.updatePoseDisplay();
        end
    
        function eStop(app)
            % Emergency Stop
            global eStopEnabled;
            eStopEnabled = true;
            app.eStopEnabled = true;
            app.enableSliders(false); 
            app.eStopButton.Enable = 'off';
            app.resumeButton.Enable = 'on';
        end

        function resume(app)
            % Resume operation
            global eStopEnabled;
            eStopEnabled = false;
            app.eStopEnabled = false;
            app.enableSliders(true);
            app.eStopButton.Enable = 'on'; 
            app.resumeButton.Enable = 'off'; 
        end
        
        function enableSliders(app, enable)
            % Enable or disable sliders
            sliderState = 'off';
            if enable
                sliderState = 'on';
            end
            for i = 1:numel(app.slidersOmron)
                app.slidersOmron(i).Enable = sliderState;
            end
            for i = 1:numel(app.slidersWelder)
                app.slidersWelder(i).Enable = sliderState;
            end
        end
        
        function updatePoseDisplay(app)
            % Display the current joint angles for Omron and Welder robots
            poseText = {
                'Omron Joint Angles:', ...
                sprintf('J1: %.2f', app.qOmron(1)), ...
                sprintf('J2: %.2f', app.qOmron(2)), ...
                sprintf('J3: %.2f', app.qOmron(3)), ...
                sprintf('J4: %.2f', app.qOmron(4)), ...
                sprintf('J5: %.2f', app.qOmron(5)), ...
                sprintf('J6: %.2f', app.qOmron(6)), ...
                '', 'Welder Joint Angles:', ...
                sprintf('J1: %.2f', app.qWelder(1)), ...
                sprintf('J2: %.2f', app.qWelder(2)), ...
                sprintf('J3: %.2f', app.qWelder(3)), ...
                sprintf('J4: %.2f', app.qWelder(4)), ...
                sprintf('J5: %.2f', app.qWelder(5)), ...
                sprintf('J6: %.2f', app.qWelder(6))
            };
            
            % Update text area
            app.poseTextArea.Value = poseText;
        end
    end
end
