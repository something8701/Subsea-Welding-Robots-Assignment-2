% main.m

% Clear workspace and command window
clear all;
clc;

% Add the folder containing your classes to the MATLAB path
addpath(genpath(pwd));

% Create an instance of the Omron TM5 robot
omron = OmronTM5();

% Plot the Omron TM5 robot in the default zero position
figure(1);
omron.plotRobot();
view(3); % Set 3D view
grid on;

% Create an instance of the Underwater Welding robot
welder = UnderwaterWelder();

% Plot the Underwater Welder robot in the default zero position
figure(2);
welder.plotRobot();
view(3); % Set 3D view
grid on;

% Move the Underwater Welder to a specified point
target_point = [0.5, 0.2, 0.3]; % Define the target point in 3D space
figure(3);
welder.moveToPoint(target_point);
view(3); % Set 3D view
grid on;
