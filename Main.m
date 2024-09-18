% main.m

% Clear workspace and command window
clear all;
clc;

% Add the folder containing your classes to the MATLAB path
addpath(genpath(pwd));

%% Initialize the Feeder Robot (Omron TM5)
feederRobot = OmronTM5();

% Visualize the Feeder Robot
figure(1);
feederRobot.plotRobot();

%% Initialize the Welding Robot (Underwater Welder)
weldingRobot = UnderwaterWelder();

% Visualize the Welding Robot
figure(2);
weldingRobot.plotRobot();

%% Create an Instance of the Movement Class
movementController = Movement(feederRobot, weldingRobot);

%% Define the Welding Path as a Series of Points
weldingPoints = [
    0.5, 0.2, 0.3;
    0.55, 0.25, 0.35;
    0.6, 0.3, 0.4;
];

%% Synchronize the Robots Along the Welding Path
movementController.synchronizeRobots(weldingPoints);
