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
     % Create Omron Object
        feederRobot = OmronTM5700();
     % For interacting with Omron
        %feederRobot.OmronTeach(q);

     % Set Goal Locations
        % Cartesian Coordinates
            Location1 = [-0.4 0.3 0.7];
            Location2 = [-0.4 0 0.7];
            Location3 = [-0.4 -0.3 0.7];
            Location4 = [-0.4 -0.3 0.1];
            Location5 = [-0.4 0 0.1];
            Location6 = [-0.4 0.3 0.1];
            
     % Move to Goal Locations
            feederRobot.OmronMoveToCartesian(Location1);
            feederRobot.OmronMoveToCartesian(Location2);
            feederRobot.OmronMoveToCartesian(Location3);
            feederRobot.OmronMoveToCartesian(Location4);
            feederRobot.OmronMoveToCartesian(Location5);
            feederRobot.OmronMoveToCartesian(Location6);
            feederRobot.OmronMoveToCartesian();