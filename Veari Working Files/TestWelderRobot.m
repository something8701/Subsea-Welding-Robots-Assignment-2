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

     % Set Goal Locations
        % Cartesian Coordinates
            Location1 = [-0.5 0.5 0.9];
            Location2 = [0 0.5 0.9];
            Location3 = [0.5 0.5 0.9];

            Location4 = [0.5 0.5 0.6];
            Location5 = [0.5 0.5 0.3];

            Location6 = [0 0.5 0.3];
            Location7 = [-0.5 0.5 0.3];

            Location8 = [-0.5 0.5 0.6];
            Location9 = [-0.5 0.5 0.9];

     % Move to Goal Locations

            welderRobot.OmronMoveToCartesian(Location1);
                pause(1);
            welderRobot.OmronMoveToCartesian(Location2);
                pause(1);
            welderRobot.OmronMoveToCartesian(Location3);
                pause(1);
            welderRobot.OmronMoveToCartesian(Location4);
                pause(1);
            welderRobot.OmronMoveToCartesian(Location5);
                pause(1);
            welderRobot.OmronMoveToCartesian(Location6);
                pause(1);
            welderRobot.OmronMoveToCartesian(Location7);
                pause(1);
            welderRobot.OmronMoveToCartesian(Location8);
                pause(1);
            welderRobot.OmronMoveToCartesian(Location9);