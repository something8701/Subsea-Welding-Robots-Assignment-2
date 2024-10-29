% DemoScriptWithCases.m
clear;
clc;
close all;

% Global flag for EStop
global eStopEnabled;
eStopEnabled = false;

% Add paths for classes (adjust the path if needed)
addpath('Classes');
addpath('Classes/OmronTM5700');
addpath('Classes/WelderRobot');

% Initialize robots
oBaseTr = transl(0, 0, 0.5);    % Omron base transformation
wBaseTr = transl(0.3, 0, 0.5);  % Welder base transformation

feederRobot = OmronTM5700(oBaseTr, 2);
welderRobot = WelderRobot(wBaseTr);

% Initialize the GUI for control
app = robotGUI();

% Ask user to choose the case
caseChoice = input('Enter case number (1 for sliders, 2 for EStop demo): ');

switch caseChoice
    case 1
        % CASE 1: Sliders Interaction
        disp('Use the sliders in the GUI to adjust robot joint positions.');
        disp('Press Ctrl+C in the command window to stop the demo.');
        
        % Set up a loop to keep the script running and allow slider adjustments
        while isvalid(app.fig)
            % Update GUI sliders based on any manual input (loop keeps GUI open)
            pause(0.1);
        end

    case 2
        % CASE 2: Movement Trajectory with EStop and Resume
        disp('Robots will move along a predefined trajectory. Use EStop and Resume buttons to control the movement.');

        % Initialize loop parameters
        qOmronInit = zeros(1, feederRobot.model.n);
        qWelderInit = zeros(1, welderRobot.model.n);

        % Define trajectory points
        trajectoryPoints = linspace(0, pi/2, 100);
        qOmronTrajectory = repmat(qOmronInit, length(trajectoryPoints), 1);
        qWelderTrajectory = repmat(qWelderInit, length(trajectoryPoints), 1);

        % Set up simple movement pattern for both robots
        for i = 1:length(trajectoryPoints)
            qOmronTrajectory(i, 2) = trajectoryPoints(i); % Move 2nd joint of Omron robot
            qWelderTrajectory(i, 3) = trajectoryPoints(i); % Move 3rd joint of Welder robot
        end

        % Main movement loop
        i = 1; % Start index for trajectory
        while true
            if ~eStopEnabled
                % Animate both robots along their trajectories
                feederRobot.model.animate(qOmronTrajectory(i, :));
                welderRobot.model.animate(qWelderTrajectory(i, :));

                % Update the current positions in the GUI sliders
                app.qOmron = qOmronTrajectory(i, :);
                app.qWelder = qWelderTrajectory(i, :);
                for j = 1:feederRobot.model.n
                    app.slidersOmron(j).Value = app.qOmron(j);
                end
                for j = 1:welderRobot.model.n
                    app.slidersWelder(j).Value = app.qWelder(j);
                end

                % Move to the next point in the trajectory
                i = i + 1;
                if i > length(trajectoryPoints)
                    i = 1; % Loop back to the beginning of the trajectory
                end
            end
            
            % Pause briefly for animation update
            pause(0.05);

            % Check if the figure is closed to exit the loop
            if ~isvalid(app.fig)
                break;
            end
        end

    otherwise
        disp('Invalid case number. Please enter 1 or 2.');
end
