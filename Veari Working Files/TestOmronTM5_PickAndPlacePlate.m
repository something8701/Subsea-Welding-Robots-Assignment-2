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
     hold on;
     % Set the view to 1-by-1-by-1
         xlim([-2 2]); % Set limits for x-axis
         ylim([-2 2]); % Set limits for y-axis
         zlim([-2 2]); % Set limits for z-axis
     % Initial Joint Config
        q = [0 0 0 0 0 0 0];
     % Create Omron Object
        feederRobot = OmronTM5700();
     % For interacting with Omron
        feederRobot.OmronTeach(q);
     % Create SteelPlate
        % SteelPlate
            h_1 = PlaceObject('SteelPlateLink0.PLY',[-0.35,0,0]);
            verts = [get(h_1,'Vertices'), ones(size(get(h_1,'Vertices'),1),1)];
            set(h_1,'Vertices',verts(:,1:3))
     % Set Goal Locations
        % Cartesian Coordinates
            Location1 = [-0.2224 -0.1223 0.8917];
            Location2 = [-0.35 0 0.3];
            Location3 = [-0.35 0 0];
            %Location4 = [-0.4 -0.3 0.1];
            %Location5 = [-0.4 0 0.1];
            %Location6 = [-0.4 0.3 0.1];

            AllLocationMatrix = [Location1;
                                Location2
                                Location3
                                ];
            [rows, cols] = size(AllLocationMatrix);
     % Create visual end effector destination markings
        plot3(AllLocationMatrix(:,1),AllLocationMatrix(:,2),AllLocationMatrix(:,3),'r*');
     % Move to Goal Locations
        % Position to pickup
            pause(2);
            feederRobot.OmronMove_FinalQKnown([pi/2 0 0 0 0 0 0]);
            pause(1);
            feederRobot.OmronMove_FinalQKnown([pi/2 0 0 0 (-pi/2) 0 0]);
            pause(1);
            feederRobot.OmronMoveToCartesian_Down(Location2);
            pause(1);
            feederRobot.OmronMoveToCartesian_Down(Location3);
            pause(1);
        % Pickup then position to default
            feederRobot.OmronMoveToCartesian_Down(Location2);
            pause(1);
            feederRobot.OmronMove_FinalQKnown([pi/2 0 0 0 (-pi/2) 0 0]);
            pause(1);
            feederRobot.OmronMove_FinalQKnown([0 0 0 0 (-pi/2) 0 0]);
            pause(1);
            %feederRobot.OmronMoveToCartesian_NegativeX([-0.1 0.7 0.7])
        % Pickup then position to place
            
        % Release then default
        
     % Delete object at the end
        %delete(h_1);