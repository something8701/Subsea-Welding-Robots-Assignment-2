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
    env = Underwater_Welding_Environment_V2(); 

    % Plot the environment
        env.plotEnvironment(gca);

%% Initialize and Plot Robots
    movement = Synchronised_Movement_V2();

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
    % app = GUI(); 
    robotGUI();

%% Create markings for weld locations
    WeldLocations = [   -0.05 0.25 1.4;      % Before start of weld
                        -0.05 0.45 1.4;      % Starts welding
                        0.15 0.45 1.4;
                        0.35 0.45 1.4;
                        0.35 0.45 1.2;
                        0.15 0.45 1.2;
                        -0.05 0.45 1.2;
                        -0.05 0.45 1.4;       % Ends welding
                        -0.05 0.25 1.4;       % After weld is complete
                        0.15,0.45,1.3          % ONLY for plotting the centre
                        ];
    [rows, cols] = size(WeldLocations);
    hold on;
    % Create visual markings
        plot3(WeldLocations(:,1),WeldLocations(:,2)-0.01,WeldLocations(:,3),'r*');
%% Do Movement - Individual Movements
    % input('Press enter to begin welding operation')
    % Move to Goal Locations
        pause(10);
        % Change View
            xlim([-1.5, 1.5]);
            ylim([-1.5, 1.5]);
            zlim([0, 2]);
        pause(1);
        % Welder robot moves out of the way AND omron moves to pickup steel plate
            movement.OmronAndWelder_MoveToq(50,[pi/2 0 0 0 0 (pi/2) 0],[-pi/2 pi/4 pi/4 0 pi/2 0 0]);
            % pause(0.5);
        % Omron is tasked with picking up the steel plate
            movement.Omron_MoveToq(50,[pi/2 0 (-pi/2) 0 (-pi/2) (pi/2) 0]);
            % pause(0.5);
            movement.Omron_MoveToCart(50,[-0.35, 0, 0.8],0,180,180);
            % pause(0.5);
            movement.Omron_MoveToCart(50,[-0.35, 0, 0.51],0,180,180);
            % pause(2);
        % Omron and steel plate moves to place steel plate
            movement.OmronSteelPlate_MoveToCart(50,[-0.35, 0, 0.8],0,180,180);
            % pause(0.5);
            movement.OmronSteelPlate_MoveToq(50,[pi/2 0 0 0 (-pi/2) (pi/2) 0]);
            % pause(0.5);
            movement.OmronSteelPlate_MoveToq(50,[(-pi/2) 0 0 0 0 (pi/2) 0]);
            % pause(0.5);
            movement.OmronSteelPlate_MoveToq(50,[(-pi/2) 0 0 0 0 (-pi/2) 0]);
            % pause(0.5);
        % Omron Moves steel plate to wall
            movement.OmronSteelPlate_MoveToCart(50,[0.15 0.3 1.3],0,-90,-90);
            % pause(0.5);
            movement.OmronSteelPlate_MoveToCart(50,[0.15 0.45 1.3],0,-90,-90);
            % pause(0.5);
        % Omron Moves away for welding to occur
            movement.Omron_MoveToCart(50,[0.15 0.3 1.3],0,-90,-90);
            % pause(0.5);
            movement.Omron_MoveToq(50,[-pi/2 0 0 0 0 0 0]);
            % pause(0.5);
        % Omron and Welder move simultaneously
        % Omron moves away AND Welder moves to do welding
            movement.OmronAndWelder_MoveToq(50,[0 0 0 0 0 0 0],[0 0 0 0 0 0 0]);
            % pause(0.5);
            movement.Omron_MoveBase(50,[0,-0.4,0.5]);
            % pause(0.5);
            movement.OmronAndWelder_MoveToq(50,[pi/2 0 0 0 (-pi/2) 0 0],[0 deg2rad(-45) deg2rad(-45) 0 0 0 0]);
            % pause(0.5);
            movement.OmronAndWelder_MoveToq(50,[(pi/2) deg2rad(80) 0 0 (-pi/2) 0 0],[0 deg2rad(-45) deg2rad(-45) 0 pi/2 0 0]);
            % pause(0.5);
        % Welder does welding
            for i = 1:rows-1
                movement.Welder_MoveToCart(50,[WeldLocations(i,:)],90,0,180);
            end
        % Omron and Welder return to default state
            movement.OmronAndWelder_MoveToq(50,[0 0 0 0 0 0 0],[0 deg2rad(-45) deg2rad(-45) 0 pi/2 0 0]);
            % pause(0.5);
            movement.Welder_MoveToq(50,[0 0 0 0 0 0 0]);
            % pause(0.5);
            movement.Omron_MoveBase(50,[0,0,0.5]);

%% Loop to allow user input for redo
    % while true
    %     userInput = input('Type "redo" to repeat the movement, or "exit" to quit: ', 's');
    %     if strcmp(userInput, 'redo')
    %         % Move robots again with the same movement
    %         feederRobot.Omron_MoveToq([pi/2 0 0 0 0 (pi/2) 0]);
    %     elseif strcmp(userInput, 'exit')
    %         break;
    %     else
    %         disp('Invalid input. Please type "redo" or "exit".');
    %     end
    % end