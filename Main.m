% Main Script

% Clear workspace and command window
clear all;
clc;
% Close all figures
close all;

% Add the directory containing your classes to the MATLAB path
addpath('Classes');
addpath('Classes/OmronTM5700');

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
welderRobot = welderRS();  % Instantiate the welder robot

% **Plot the welderRobot**
welderRobot.plotRobot();

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
xlim(hAxes, [-5, 5]);
ylim(hAxes, [-5, 5]);
zlim(hAxes, [0, 5]);

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

%% Define the movement points
% Define start point and end point (in a straight line)
startPoint = [0.3, 0, 0.4];   % Start position (X, Y, Z)
endPoint = [0.3, 0.3, 0.4];   % End position in a straight line (move along Y)

% Create Movement class for synchronized robot motion
movement = Movement(feederRobotWrapper, welderRobot, hAxes);

% Move the robots with a delay for slowing down
delayPerStep = 0.05; % Adjust the delay time (in seconds)
movement.moveStraightLine(startPoint, endPoint, delayPerStep);

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
