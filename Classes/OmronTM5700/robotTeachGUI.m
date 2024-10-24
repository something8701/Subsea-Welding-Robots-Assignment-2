% %% GUI TEST PROBS WONT USE THIS ONE.... 
% 
% classdef robotTeachGUI < handle
%     properties
%         % GUI Components
%         fig
%         hAxes
%         jointSliders
%         cartesianFields
%         eStopButton
%         resumeButton
%         % Robots
%         feederRobot
%         welderRobot
%         % State Variables
%         qFeeder
%         qWelder
%         isStopped = false
%         % Other properties as needed
%     end
% 
%     methods
%         function self = robotTeachGUI()
%             % Constructor: Initialize the GUI and robots
%             self.createGUI();
%             self.initializeRobots();
%         end
% 
%         % Method to create GUI components
%         function createGUI(self)
%             % Create the main GUI window
%             self.fig = figure('Name', 'Robot Teach GUI', 'Position', [100, 100, 800, 600]);
% 
%             % Set up axes for plotting robots
%             self.hAxes = axes('Parent', self.fig, 'Position', [0.05, 0.4, 0.9, 0.55]);
%             hold(self.hAxes, 'on');
%             grid(self.hAxes, 'on');
%             axis(self.hAxes, 'equal');
%             xlim(self.hAxes, [-5, 5]);
%             ylim(self.hAxes, [-5, 5]);
%             zlim(self.hAxes, [0, 5]);
% 
%             % Create UI panels and controls
%             self.createJointControlPanel();
%             self.createCartesianControlPanel();
%             self.createEStopControls();
% 
%             % Set up callbacks and other UI properties
%             % ...
%         end
% 
%         % Method to initialize robots
%         function initializeRobots(self)
%             % Instantiate robots
%             self.feederRobot = OmronTM5700();
%             self.welderRobot = welderRS();
% 
%             % Initial joint configurations
%             self.qFeeder = zeros(1, 7);
%             self.qWelder = zeros(1, 6);
% 
%             % Plot robots
%             self.feederRobot.model.plot(self.qFeeder, 'Parent', self.hAxes);
%             self.welderRobot.robot.plot(self.qWelder, 'Parent', self.hAxes);
%         end
% 
%         % Method to create joint control panel
%         function createJointControlPanel(self)
%             % Create a panel for joint controls
%             jointPanel = uipanel('Parent', self.fig, 'Title', 'Joint Control', 'Position', [0.05, 0.05, 0.4, 0.3]);
% 
%             % Create sliders and labels for each joint
%             self.jointSliders = gobjects(7, 1);  % Preallocate for 7 joints
%             for i = 1:7
%                 % Joint label
%                 uicontrol('Parent', jointPanel, 'Style', 'text', 'String', ['Joint ', num2str(i)], ...
%                     'Units', 'normalized', 'Position', [0.05, 0.9 - (i-1)*0.12, 0.1, 0.08]);
% 
%                 % Joint slider
%                 self.jointSliders(i) = uicontrol('Parent', jointPanel, 'Style', 'slider', ...
%                     'Min', -pi, 'Max', pi, 'Value', 0, ...
%                     'Units', 'normalized', 'Position', [0.15, 0.9 - (i-1)*0.12, 0.8, 0.08], ...
%                     'Callback', @(src, event) self.jointSliderChanged(src, i));
%             end
%         end
% 
%         % Method to create Cartesian control panel
%         function createCartesianControlPanel(self)
%             % Create a panel for Cartesian controls
%             cartesianPanel = uipanel('Parent', self.fig, 'Title', 'Cartesian Control', 'Position', [0.55, 0.05, 0.4, 0.3]);
% 
%             % X position
%             uicontrol('Parent', cartesianPanel, 'Style', 'text', 'String', 'X:', ...
%                 'Units', 'normalized', 'Position', [0.1, 0.7, 0.1, 0.1]);
%             self.cartesianFields(1) = uicontrol('Parent', cartesianPanel, 'Style', 'edit', 'String', '0', ...
%                 'Units', 'normalized', 'Position', [0.2, 0.7, 0.7, 0.1], ...
%                 'Callback', @(src, event) self.cartesianFieldChanged());
% 
%             % Y position
%             uicontrol('Parent', cartesianPanel, 'Style', 'text', 'String', 'Y:', ...
%                 'Units', 'normalized', 'Position', [0.1, 0.5, 0.1, 0.1]);
%             self.cartesianFields(2) = uicontrol('Parent', cartesianPanel, 'Style', 'edit', 'String', '0', ...
%                 'Units', 'normalized', 'Position', [0.2, 0.5, 0.7, 0.1], ...
%                 'Callback', @(src, event) self.cartesianFieldChanged());
% 
%             % Z position
%             uicontrol('Parent', cartesianPanel, 'Style', 'text', 'String', 'Z:', ...
%                 'Units', 'normalized', 'Position', [0.1, 0.3, 0.1, 0.1]);
%             self.cartesianFields(3) = uicontrol('Parent', cartesianPanel, 'Style', 'edit', 'String', '0', ...
%                 'Units', 'normalized', 'Position', [0.2, 0.3, 0.7, 0.1], ...
%                 'Callback', @(src, event) self.cartesianFieldChanged());
%         end
% 
%         % Method to create E-stop controls
%         function createEStopControls(self)
%             % E-stop Button
%             self.eStopButton = uicontrol('Parent', self.fig, 'Style', 'pushbutton', 'String', 'E-STOP', ...
%                 'BackgroundColor', 'red', 'ForegroundColor', 'white', 'FontSize', 12, ...
%                 'Units', 'normalized', 'Position', [0.45, 0.35, 0.1, 0.05], ...
%                 'Callback', @(src, event) self.eStopPressed());
% 
%             % Resume Button (initially disabled)
%             self.resumeButton = uicontrol('Parent', self.fig, 'Style', 'pushbutton', 'String', 'Resume', ...
%                 'Enable', 'off', 'FontSize', 12, ...
%                 'Units', 'normalized', 'Position', [0.55, 0.35, 0.1, 0.05], ...
%                 'Callback', @(src, event) self.resumePressed());
%         end
% 
%         % Callback methods
%         function jointSliderChanged(self, src, jointIndex)
%             if self.isStopped
%                 return;  % Do nothing if E-stop is engaged
%             end
%             % Get the slider value
%             angle = get(src, 'Value');
%             % Update joint angle
%             self.qFeeder(jointIndex) = angle;
%             % Update robot pose
%             self.feederRobot.model.animate(self.qFeeder);
%         end
% 
%         function cartesianFieldChanged(self)
%             if self.isStopped
%                 return;  % Do nothing if E-stop is engaged
%             end
%             % Get desired Cartesian position
%             x = str2double(get(self.cartesianFields(1), 'String'));
%             y = str2double(get(self.cartesianFields(2), 'String'));
%             z = str2double(get(self.cartesianFields(3), 'String'));
% 
%             if isnan(x) || isnan(y) || isnan(z)
%                 errordlg('Please enter valid numeric values for X, Y, Z.', 'Input Error');
%                 return;
%             end
% 
%             % Compute inverse kinematics
%             T = transl([x, y, z]);
%             qSol = self.feederRobot.model.ikcon(T, self.qFeeder);
%             if ~isempty(qSol)
%                 self.qFeeder = qSol;
%                 % Update robot pose
%                 self.feederRobot.model.animate(self.qFeeder);
%                 % Update joint sliders
%                 for i = 1:length(self.jointSliders)
%                     set(self.jointSliders(i), 'Value', self.qFeeder(i));
%                 end
%             else
%                 errordlg('Inverse kinematics solution not found.', 'IK Error');
%             end
%         end
% 
%         function eStopPressed(self)
%             % Engage E-stop
%             self.isStopped = true;
%             % Disable controls
%             set(findall(self.fig, '-property', 'Enable'), 'Enable', 'off');
%             set(self.eStopButton, 'Enable', 'on');
%             set(self.resumeButton, 'Enable', 'on');
%         end
% 
%         function resumePressed(self)
%             % First action: Confirm resume
%             choice = questdlg('Are you sure you want to resume operations?', ...
%                 'Confirm Resume', 'Yes', 'No', 'No');
%             if strcmp(choice, 'Yes')
%                 % Second action: Re-enable controls
%                 self.isStopped = false;
%                 set(findall(self.fig, '-property', 'Enable'), 'Enable', 'on');
%             end
%         end
% 
%         % Additional methods for jogging, joystick integration, etc.
%         % ...
%     end
% end
% 

function robotTeachGUI
    % Create a figure for the GUI
    f = figure('Name', 'Robot Teach Pendant', 'Position', [100 100 600 400]);

    % Create the robot object
    robot = OmronTM5700();  % You need to have this class available

    % Initialize the joint configuration
    qRobot = zeros(1, robot.model.n);  % Assuming robot has 6 DOF

    % Plot the robot in the initial configuration
    axesHandle = axes(f, 'Position', [0.3 0.2 0.6 0.7]);  % Axes for robot visualization
    robot.model.plot(qRobot, 'workspace', [-1 1 -1 1 0 1]);
    hold on;

    % Create sliders for each joint (Link)
    sliderHandles = gobjects(1, 5);  % Preallocate with gobjects to store slider handles properly
    for i = 1:5
        % Create sliders and labels for each joint (link)
        uicontrol('Style', 'text', 'Position', [20 350 - (i * 50) 50 20], 'String', ['Link ' num2str(i)]);
        sliderHandles(i) = uicontrol('Style', 'slider', 'Min', -pi, 'Max', pi, 'Value', 0, ...
            'Position', [80 350 - (i * 50) 150 20], 'ValueChangingFcn', @(src, event) updateJoint(i, event));
    end

    % Create E-Stop button
    eStopButton = uicontrol('Style', 'pushbutton', 'String', 'E-Stop', ...
        'Position', [50 50 100 40], 'Callback', @eStopPressed);

    % Create Resume button (initially disabled)
    resumeButton = uicontrol('Style', 'pushbutton', 'String', 'Resume', ...
        'Position', [200 50 100 40], 'Enable', 'off', 'Callback', @resumePressed);

    % Update robot joint configuration when sliders are moved
    function updateJoint(linkNum, event)
        % Get the continuously changing value for the corresponding link
        qRobot(linkNum) = event.Value;  % Use event.Value for live updates while moving the slider
        % Animate the robot with the new joint configuration
        robot.model.animate(qRobot);
    end

    % E-Stop functionality
    function eStopPressed(~, ~)
        % Disable all sliders to stop joint movement
        for i = 1:6
            sliderHandles(i).Enable = 'off';
        end
        % Disable E-Stop and enable Resume
        eStopButton.Enable = 'off';
        resumeButton.Enable = 'on';
        disp('Robot Stopped. Emergency Stop Activated.');
    end

    % Resume functionality
    function resumePressed(~, ~)
        % Re-enable all sliders to allow joint movement
        for i = 1:6
            sliderHandles(i).Enable = 'on';
        end
        % Disable Resume and enable E-Stop
        resumeButton.Enable = 'off';
        eStopButton.Enable = 'on';
        disp('Robot Resumed.');
    end
end

