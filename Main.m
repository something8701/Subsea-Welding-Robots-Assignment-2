% main.m

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

%% Plot the Environment
env = Environment(10, 10); % Adjust NX and NY as needed
env.plotEnvironment(hAxes);

%% Initialize the Feeder Robot (Omron TM5)
feederRobot = OmronTM5();

%% Initialize the Welding Robot (Underwater Welder)
weldingRobot = UnderwaterWelder();

%% Visualize the Robots in the Same Axes
feederRobot.plotRobot([], hAxes);
weldingRobot.plotRobot([], hAxes);

%% Create an Instance of the Movement Class
movementController = Movement(feederRobot, weldingRobot, hAxes);

%% Define the Welding Path as a Series of Points
weldingPoints = [
    0.5, 0.2, 0.3;
    0.55, 0.25, 0.35;
    0.6, 0.3, 0.4;
];

%% Synchronize the Robots Along the Welding Path
movementController.synchronizeRobots(weldingPoints);
