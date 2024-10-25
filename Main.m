% Main Script

% Clear workspace and command window
clear;
clc;
% Close all figures
close all;

% Add the directory containing your classes to the MATLAB path
addpath('Classes');
addpath('Classes/OmronTM5700');
addpath('Classes/WelderRobot');

%% Initialize Environment
env = Environment(); 

% Add the welderRS model to the environment (avoid re-importing)
if isempty(env.welderModel)
    env.welderModel = welderRS();  % Changed to welderRS
end

% Plot the environment and welder
env.plotEnvironment(gca);

%% Initialize and Plot Robots
% Initialize the OmronTM5700
feederRobot = OmronTM5700();  % Instantiate the feeder robot

% Create a wrapper object that has a 'robot' property pointing to 'feederRobot.model'
feederRobotWrapper = struct();
feederRobotWrapper.robot = feederRobot.model;

% Initialize the welderRS Robot
welderRobot = WelderRobot();  % Instantiate the welder robot

% Adjust Axes Properties
% Get the figure and axes handles
hFig = gcf;
hAxes = gca;
hold(hAxes, 'on'); % Hold on to plot multiple items in the same axes

% Set axes background color to white
set(hAxes, 'Color', [1 1 1]);
% Set grid properties
set(hAxes, 'GridColor', [0 0 0]); % Grid lines in black
grid(hAxes, 'on');                % Turn on grid
% Adjust axes limits and aspect ratio
axis(hAxes, 'equal');
xlim(hAxes, [-2.5, 2.5]);
ylim(hAxes, [-2.5, 2.5]);
zlim(hAxes, [0, 3]);

% Add Lighting and Material Effects
% Add a light source
camlight('headlight');
% Set material properties
material(hAxes, 'dull');

% Set View and Renderer
% Set 3D view
view(hAxes, 3);
% Set renderer to OpenGL for better lighting effects
set(hFig, 'Renderer', 'opengl');

%% Initialise GUI
app = GUI(); 

% Set up callbacks to update robot joint movements
addlistener(app.Link1, 'ValueChanged', @(src, event) updateJoint(1, app, feederRobotWrapper.robot));
addlistener(app.Link2, 'ValueChanged', @(src, event) updateJoint(2, app, feederRobotWrapper.robot));
addlistener(app.Link3, 'ValueChanged', @(src, event) updateJoint(3, app, feederRobotWrapper.robot));
addlistener(app.Link4, 'ValueChanged', @(src, event) updateJoint(4, app, feederRobotWrapper.robot));
addlistener(app.Link5, 'ValueChanged', @(src, event) updateJoint(5, app, feederRobotWrapper.robot));

% Function to update robot joints
function updateJoint(jointNum, app, robot)
    % Update the robot joint angle based on the slider value
    qRobot(jointNum) = app.(['Link', num2str(jointNum)]).Value;  % Get slider value
    robot.animate(qRobot);  % Update robot pose
end

% Handle Cartesian movements (X, Y, Z inputs)
addlistener(app.X, 'ValueChanged', @(src, event) updateCartesian(app, feederRobotWrapper.robot));
addlistener(app.Y, 'ValueChanged', @(src, event) updateCartesian(app, feederRobotWrapper.robot));
addlistener(app.Z, 'ValueChanged', @(src, event) updateCartesian(app, feederRobotWrapper.robot));

% Function to update robot based on XYZ inputs (inverse kinematics)
function updateCartesian(app, robot)
    % Get the desired Cartesian position from the GUI inputs
    x = app.X.Value;
    y = app.Y.Value;
    z = app.Z.Value;

    % Compute the target transformation matrix
    T = transl([x, y, z]);

    % Solve for joint angles using inverse kinematics
    qSol = robot.ikcon(T, robot.getpos());

    % If a valid solution is found, update the robot configuration
    if ~isempty(qSol)
        robot.animate(qSol);
    else
        disp('No valid IK solution found');
    end
end

% %% Define the movement points
% % Define start point and end point (in a straight line)
% startPoint = [0.3, 0, 0.4];   % Start position (X, Y, Z)
% endPoint = [0.3, 0.3, 0.4];   % End position in a straight line (move along Y)
% 
% % Create Movement class for synchronized robot motion
% movement = Movement(feederRobotWrapper, welderRobot, hAxes);
% 
% % Move the robots with a delay for slowing down
% delayPerStep = 0.05; % Adjust the delay time (in seconds)
% movement.moveStraightLine(startPoint, endPoint, delayPerStep);

%% Loop to allow user input for redo
while true
    userInput = input('Type "redo" to repeat the movement, or "exit" to quit: ', 's');
    if strcmp(userInput, 'redo')
        % Move robots again with the same movement
        movement.moveStraightLine(startPoint, endPoint, delayPerStep);
    elseif strcmp(userInput, 'exit')
        break;
    else
        disp('Invalid input. Please type "redo" or "exit".');
    end
end
