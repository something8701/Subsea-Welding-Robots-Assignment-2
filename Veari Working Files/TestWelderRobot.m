 % Create the Omron TM5 (Assume TM5-700)
     clf
     clc
 % Create 3D surface plot of floor.
     surf([-1.0,-1.0;1.0,1.0] ...                % X-coordinates of surface
         ,[-1.0,1.0;-1.0,1.0] ...                % Y-coordinates of surface
         ,[0,0;0,0] ...                          % Z-coordinates of surface (flat plane)
         ,'CData',imread('concrete.jpg') ...
         ,'FaceColor','texturemap');
     camlight;                                   % Run this once
     axis equal;                                 % Equal scaling for all axes
     % Set the view to 1-by-1-by-1
         xlim([-1.5 1.5]); % Set limits for x-axis
         ylim([-1.5 1.5]); % Set limits for y-axis
         zlim([-0.5 1.5]); % Set limits for z-axis
     % Initial Joint Config
        q = [0 0 0 0 0 0 0];
     % Create WelderRobot Object
        welderRobot = WelderRobot();
     % For interacting with Omron
        %feederRobot.OmronTeach(q);
     
     % Create markings to see if it reaches the point
        WeldLocations = [ -0.13 0.36 1.08      % Default State
                            -0.3 0.5 0.9;      % Before start of weld
                            -0.3 0.7 0.9;      % Starts welding
                            -0.1 0.7 0.9;
                            0.1 0.7 0.9;
                            0.1 0.7 0.7;
                            0.1 0.7 0.5;
                            -0.1 0.7 0.5;
                            -0.3 0.7 0.5;
                            -0.3 0.7 0.7;
                            -0.3 0.7 0.9        % Ends welding
                            -0.3 0.5 0.9        % After weld is complete
                            -0.13 0.36 1.08     % Default state
                            ];
        [rows, cols] = size(WeldLocations);
        hold on;
     % Create visual markings
        plot3(WeldLocations(:,1),WeldLocations(:,2),WeldLocations(:,3),'r*');

     % Set Goal Locations

     % Move to Goal Locations
        for i = 1:rows
            welderRobot.OmronMoveToCartesian(WeldLocations(i,:));
            pause(1);
        end
     % Find default end effector transform
            q1 = [0 0 0 0 deg2rad(90) 0 0];
            welderRobot.OmronFkine(q1)