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
    env = Welding_Environment(); 

    % Plot the environment
        env.plotEnvironment(gca);

    % Place ROV
        ROV = PlaceObject('ROV.PLY',[0,-0.2,0]);
        verts = [get(ROV,'Vertices'), ones(size(get(ROV,'Vertices'),1),1)];
        set(ROV,'Vertices',verts(:,1:3))
    % Place Plate
        Plate = PlaceObject('SteelPlate.PLY',[-0.35,0,0.5]);
        verts = [get(Plate,'Vertices'), ones(size(get(Plate,'Vertices'),1),1)];
        set(Plate,'Vertices',verts(:,1:3))
    % Place Stop Button
        Stop = PlaceObject('StopButton.ply',[0.3,-0.5,0.5]);
        verts = [get(Stop,'Vertices'), ones(size(get(Stop,'Vertices'),1),1)];
        set(Stop,'Vertices',verts(:,1:3))
    % Place Stop Button
        Stop = PlaceObject('StopButton.ply',[-2.5,-2.5,0]);
        verts = [get(Stop,'Vertices'), ones(size(get(Stop,'Vertices'),1),1)];
        set(Stop,'Vertices',verts(:,1:3))

%% Initialize and Plot Robots
    % Initialize the OmronTM5700
        oBaseTr = transl(0,0,0.5);
        feederRobot = OmronTM5700(oBaseTr,2);    % Instantiate the feeder robot - At origin
                                                  % Plots steel plate (Case 2)
    % Initialize the welderRS Robot
        wBaseTr = transl(0.3,0,0.5);
        welderRobot = WelderRobot(wBaseTr);        % Instantiate the welder robot - At (0.35, 0, 0)

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

% % Set up callbacks to update robot joint movements
%     addlistener(app.Link1, 'ValueChanged', @(src, event) updateJoint(1, app, feederRobotWrapper.robot));
%     addlistener(app.Link2, 'ValueChanged', @(src, event) updateJoint(2, app, feederRobotWrapper.robot));
%     addlistener(app.Link3, 'ValueChanged', @(src, event) updateJoint(3, app, feederRobotWrapper.robot));
%     addlistener(app.Link4, 'ValueChanged', @(src, event) updateJoint(4, app, feederRobotWrapper.robot));
%     addlistener(app.Link5, 'ValueChanged', @(src, event) updateJoint(5, app, feederRobotWrapper.robot));
% 
% % Function to update robot joints
%     function updateJoint(jointNum, app, robot)
%         % Update the robot joint angle based on the slider value
%         qRobot(jointNum) = app.(['Link', num2str(jointNum)]).Value;  % Get slider value
%         robot.animate(qRobot);  % Update robot pose
%     end
% 
% % Handle Cartesian movements (X, Y, Z inputs)
%     addlistener(app.X, 'ValueChanged', @(src, event) updateCartesian(app, feederRobotWrapper.robot));
%     addlistener(app.Y, 'ValueChanged', @(src, event) updateCartesian(app, feederRobotWrapper.robot));
%     addlistener(app.Z, 'ValueChanged', @(src, event) updateCartesian(app, feederRobotWrapper.robot));
% 
% % Function to update robot based on XYZ inputs (inverse kinematics)
%     function updateCartesian(app, robot)
%         % Get the desired Cartesian position from the GUI inputs
%         x = app.X.Value;
%         y = app.Y.Value;
%         z = app.Z.Value;
% 
%         % Compute the target transformation matrix
%         T = transl([x, y, z]);
% 
%         % Solve for joint angles using inverse kinematics
%         qSol = robot.ikcon(T, robot.getpos());
% 
%         % If a valid solution is found, update the robot configuration
%         if ~isempty(qSol)
%             robot.animate(qSol);
%         else
%             disp('No valid IK solution found');
%         end
%     end

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
    input('Press enter to begin welding operation')
    % Move to Goal Locations
        % Welder moves out of the way
            welderRobot.WelderMove_FinalQInput([-pi/2 pi/4 pi/4 0 pi/2 0 0]);
        % Change View
            xlim([-1, 1]);
            ylim([-1, 0.75]);
            zlim([0, 2]);
        % Omron position to pickup
            feederRobot.Omron_MoveToq([pi/2 0 0 0 0 (pi/2) 0]);
            feederRobot.Omron_MoveToq([pi/2 0 (-pi/2) 0 (-pi/2) (pi/2) 0]);
            feederRobot.Omron_MoveToCartesian([-0.35, 0, 0.8],0,180,180);
            feederRobot.Omron_MoveToCartesian([-0.35, 0, 0.51],0,180,180);
            pause(2);
        % Omron Picksup steel plate then moves to default position
            delete(Plate);
            feederRobot.OmronAndSteel_MoveToCartesian([-0.35, 0, 0.8],0,180,180);
            pause(1);
            feederRobot.OmronAndSteel_MoveToq([pi/2 0 0 0 (-pi/2) (pi/2) 0]);
            pause(1);
            feederRobot.OmronAndSteel_MoveToq([(-pi/2) 0 0 0 0 (pi/2) 0]);
            pause(1);
            feederRobot.OmronAndSteel_MoveToq([(-pi/2) 0 0 0 0 (-pi/2) 0]);
            pause(1);
        % Omron Moves steel plate to wall
            feederRobot.OmronAndSteel_MoveToCartesian([0.15 0.3 1.3],0,-90,-90);
            feederRobot.OmronAndSteel_MoveToCartesian([0.15 0.44 1.3],0,-90,-90);
            pause(2);
        % Omron Move Omron away for welding to occur
            feederRobot.Omron_MoveToCartesian([0.15 0.3 1.3],0,-90,-90);
            feederRobot.OmronMoveBase([0,-0.4,0.5]);
            feederRobot.Omron_MoveToq([-pi/2 0 0 0 0 0 0]);
            feederRobot.Omron_MoveToq([pi/2 0 0 0 (-pi/2) 0 0]);
            feederRobot.Omron_MoveToq([(pi/2) deg2rad(80) 0 0 (-pi/2) 0 0]);
        % Welder does welding
                welderRobot.WelderMove_FinalQInput([0 0 0 0 0 0 0]);
                welderRobot.WelderMove_FinalQInput([0 deg2rad(-45) deg2rad(-45) 0 0 0 0]);
                welderRobot.WelderMove_FinalQInput([0 deg2rad(-45) deg2rad(-45) 0 pi/2 0 0]);
            % Move to Goal Locations
            for i = 1:rows-1
                welderRobot.WelderMoveToCartesian([WeldLocations(i,:)],90,0,180);
            end
            % Welder returns to default
                welderRobot.WelderMove_FinalQInput([0 deg2rad(-45) deg2rad(-45) 0 pi/2 0 0]);
                welderRobot.WelderMove_FinalQInput([0 0 0 0 0 0 0]);
            feederRobot.Omron_MoveToq([0 0 0 0 0 0 0]);
            feederRobot.OmronMoveBase([0,0,0.5]);
%% Loop to allow user input for redo
    while true
        userInput = input('Type "redo" to repeat the movement, or "exit" to quit: ', 's');
        if strcmp(userInput, 'redo')
            % Move robots again with the same movement
            feederRobot.Omron_MoveToq([pi/2 0 0 0 0 (pi/2) 0]);
        elseif strcmp(userInput, 'exit')
            break;
        else
            disp('Invalid input. Please type "redo" or "exit".');
        end
    end
