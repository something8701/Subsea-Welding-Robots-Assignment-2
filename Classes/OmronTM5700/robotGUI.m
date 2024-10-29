classdef robotGUI < handle
    properties
        fig           % Main GUI figure
        sliders       % Array of sliders for joint control
        robot         % Robot model (assumed to be SerialLink)
        qRobot        % Joint configuration
    end
    
    methods
        function app = robotGUI()
            % Initialize the robot
            app.robot = OmronTM5700();  % Replace with your robot model
            app.qRobot = zeros(1, app.robot.model.n); % Initialize joint angles
            
            % Create GUI
            app.createGUI();
            
            % Plot the robot in the GUI
            app.updatePlot();
        end
        
        function createGUI(app)
            % Create the main figure window
            app.fig = uifigure('Name', 'Robot Teach Pendant', 'Position', [100, 100, 400, 600]);
            
            % Define slider limits based on joint limits (adjust as necessary)
            jointLimits = app.robot.model.qlim; % Assuming qlim exists for each link in the model
            
            % Create sliders for each joint
            numJoints = app.robot.model.n;
            app.sliders = gobjects(1, numJoints); % Preallocate slider array
            
            for i = 1:numJoints
                % Label for each joint
                uilabel(app.fig, 'Text', sprintf('Joint %d', i), ...
                    'Position', [20, 600 - 60*i, 60, 22]);
                
                % Ensure joint limits are valid
                if isnan(jointLimits(i, 1)) || isnan(jointLimits(i, 2)) || jointLimits(i, 1) >= jointLimits(i, 2)
                    jointLimits(i, :) = [-pi, pi]; % Set default limits if invalid
                end
                
                % Slider for each joint with jog functionality
                app.sliders(i) = uislider(app.fig, ...
                    'Limits', jointLimits(i, :), ...
                    'Value', app.qRobot(i), ...
                    'Position', [100, 600 - 60*i, 250, 3], ...
                    'ValueChangingFcn', @(src, event)app.jogJoint(i, event.Value)); % Jogging on slide
            end
        end
        
        function jogJoint(app, jointIndex, value)
            % Update the specific joint angle while the slider is moving
            app.qRobot(jointIndex) = value;
            app.updatePlot();
        end
        
        function updatePlot(app)
            % Plot robot in a separate MATLAB figure window for visualization
            figureHandle = findall(0, 'Type', 'Figure', 'Name', 'Robot View');
            if isempty(figureHandle)
                figureHandle = figure('Name', 'Robot View');
                view(3);
                axis([-1 1 -1 1 -1 1]);
                hold on;
            else
                figure(figureHandle); % Bring the figure to focus
            end
            app.robot.model.plot(app.qRobot); % Animate robot with updated joint angles
        end
    end
end
