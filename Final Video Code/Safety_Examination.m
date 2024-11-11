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
    % robotGUI();

%% Do Movement - Individual Movements
    % input('Press enter to begin welding operation')
    % Move to Goal Locations
        input('Press Enter to continue...');
        % Change View
            xlim([-2.7, -2]);
            ylim([-2.7, -2]);
            zlim([0, 1]);
        input('Press Enter to continue...');
        % Change View
            xlim([-1, 1.25]);
            ylim([-1, 1]);
            zlim([0, 1]);
        input('Press Enter to continue...');
        % Change View
            xlim([-1, 1.25]);
            ylim([-1, 1]);
            zlim([0, 2]);
        
        

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