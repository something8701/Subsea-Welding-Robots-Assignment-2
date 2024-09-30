% Clear workspace and command window
clear all;
clc;
% Close all figures
close all;

%% Initialize Environment
env = Environment();

% Get the figure and axes handles
hFig = gcf;
hAxes = gca;
hold(hAxes, 'on'); % Hold on to plot multiple items in the same axes

%% Initialize and Plot Robots
% Initialize the OmronTM5
feederRobot = OmronTM5();
% Plot feederRobot
feederRobot.plotRobot();

% Initialize the AMS Feeder Robot
amsFeederRobot = AMSFeeder();
% Plot amsFeederRobot
amsFeederRobot.plotRobot();

%% Adjust Axes Properties
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

%% Add Lighting and Material Effects
% Add a light source
camlight('headlight');
% Set material properties
material(hAxes, 'dull');

%% Set View and Renderer
% Set 3D view
view(hAxes, 3);
% Set renderer to OpenGL for better lighting effects
set(hFig, 'Renderer', 'opengl');

%% Optionally, Re-Plot the Environment
env.plotEnvironment(hAxes);

%% Veari - TEST OMRON MOVEMENT AS IF WELDING IN SQUARE MOTION
    p1 = [0 -0.5 0.5];
    p2 = [0 -0.5 1];
    p3 = [0 0 1];
    p4 = [0 0 0.5];
    p5 = [0 -0.5 0.5];
    feederRobot.moveToPoint(p1);
    feederRobot.moveToPoint(p2);
    feederRobot.moveToPoint(p3);
    feederRobot.moveToPoint(p4);
    feederRobot.moveToPoint(p5);
    
%%