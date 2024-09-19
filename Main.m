% Clear workspace and command window
clear all;
clc;

% Add the folder containing your classes to the MATLAB path
addpath(genpath(pwd));

%% Create a Figure and Axes
figure(1);
clf;
hAxes = axes('Parent', gcf);
hold(hAxes, 'on');

%% Plot the Environment (give it priority)
env = Environment(10, 10); % Adjust NX and NY as needed
env.plotEnvironment(hAxes);
uistack(hAxes, 'bottom'); % Ensure the environment is at the bottom layer

%% Initialize the Feeder Robot (Omron TM5)
feederRobot = OmronTM5(); % Ensure the OmronTM5 class is loaded

%% Initialize the AMS Feeder Robot
amsFeederRobot = AMSFeeder();

%% Visualize the Robots
feederRobot.plotRobot([], hAxes);
amsFeederRobot.plotRobot([], hAxes);

%% Create an Instance of the Movement Class
movementController = Movement(feederRobot, amsFeederRobot, hAxes);

%% Define a Straight Line Path (start and end point)
startPoint = [0.5, 0.2, 0.3]; % Starting position
endPoint = [0.7, 0.2, 0.3]; % End position

%% Linear Interpolation to Generate Points Along the Straight Line
nPoints = 20; % Number of points for path discretization
weldingPoints = [linspace(startPoint(1), endPoint(1), nPoints)', ...
                 linspace(startPoint(2), endPoint(2), nPoints)', ...
                 linspace(startPoint(3), endPoint(3), nPoints)'];

%% Synchronize the Robots Along the Welding Path with Smooth Motion
movementController.synchronizeRobots(weldingPoints);
