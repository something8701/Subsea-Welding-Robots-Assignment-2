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
    env = Environment_Veari_Test(); 

    % Plot the environment
        env.plotEnvironment(gca);

%% Initialize and Plot Robots
    % Initialize the OmronTM5700
        feederRobot = OmronTM5700([eye(4)],2);    % Instantiate the feeder robot - At origin
                                                  % Plots steel plate (Case 2)
    % Initialize the welderRS Robot
        BaseTr = eye(4) * transl(0.3,0,0);
        welderRobot = WelderRobot(BaseTr);  % Instantiate the welder robot - At (0.35, 0, 0)

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

%% Create markings for weld locations
    WeldLocations = [   -0.05 0.25 0.9;      % Before start of weld
                        -0.05 0.45 0.9;      % Starts welding
                        0.15 0.45 0.9;
                        0.35 0.45 0.9;
                        0.35 0.45 0.7;
                        0.15 0.45 0.7;
                        -0.05 0.45 0.7;
                        -0.05 0.45 0.9;       % Ends welding
                        -0.05 0.25 0.9;       % After weld is complete
                        0.15,0.45,0.8          % ONLY for plotting the centre
                        ];
    [rows, cols] = size(WeldLocations);
    hold on;
    % Create visual markings
        plot3(WeldLocations(:,1),WeldLocations(:,2)-0.01,WeldLocations(:,3),'r*');
%% Do Movement - Individual Movements
     % Move to Goal Locations
        % Welder moves out of the way
            welderRobot.WelderMove_FinalQInput([-pi/2 pi/4 pi/4 0 pi/2 0 0]);
        % Omron position to pickup
            feederRobot.OmronMove_FinalQInput([pi/2 0 0 0 0 0 0]);
            feederRobot.OmronMove_FinalQInput([pi/2 0 0 0 (-pi/2) 0 0]);
            feederRobot.Omron_MoveToCartesian_Down([-0.35 0 0.3]);
            feederRobot.Omron_MoveToCartesian_Down([-0.35 0 0]);
        % Omron Picksup steel plate then moves to default position
            feederRobot.OmronAndSteel_MoveToCartesian_Down([-0.35 0 0.3]);
            feederRobot.OmronAndSteelMove_FinalQInput([pi/2 0 0 0 (-pi/2) 0 0]);
            feederRobot.OmronAndSteelMove_FinalQInput([0 0 0 0 (-pi/2) 0 0]);
        % Omron Moves steel plate to wall
            feederRobot.OmronAndSteel_MoveToCartesian_Wall([0.15 0.35 0.8]);
            feederRobot.OmronAndSteel_MoveToCartesian_Wall([0.15 0.45 0.8]);
        % Omron Move Omron away for welding to occur
            feederRobot.OmronMoveToCartesian_Wall([0.15 0.35 0.8]);
            feederRobot.OmronMove_FinalQInput([-pi/2 0 (-pi/4) 0 0 0 0]);
            feederRobot.OmronMove_FinalQInput([-pi/2 0 0 0 0 0 0]);
            feederRobot.OmronMove_FinalQInput([pi/2 0 0 0 (-pi/2) 0 0]);
            feederRobot.OmronMoveBase([0,-0.5,0]);
        % Welder does welding
                welderRobot.WelderMove_FinalQInput([0 0 0 0 0 0 0]);
                welderRobot.WelderMove_FinalQInput([0 0 0 0 pi/2 0 0]);
            % Move to Goal Locations
            for i = 1:rows-1
                welderRobot.WelderMoveToCartesian([WeldLocations(i,:)],90,0,180);
            end
            % Welder returns to default
                welderRobot.WelderMove_FinalQInput([0 0 0 0 pi/2 0 0]);
                welderRobot.WelderMove_FinalQInput([0 0 0 0 0 0 0]);

%% Loop to allow user input for redo
    % while true
    %     userInput = input('Type "redo" to repeat the movement, or "exit" to quit: ', 's');
    %     if strcmp(userInput, 'redo')
    %         % Move robots again with the same movement
    %         movement.moveStraightLine(startPoint, endPoint, delayPerStep);
    %     elseif strcmp(userInput, 'exit')
    %         break;
    %     else
    %         disp('Invalid input. Please type "redo" or "exit".');
    %     end
    % end
