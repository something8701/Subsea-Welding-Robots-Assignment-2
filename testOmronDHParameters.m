 % Create the Omron TM5 (Assume TM5-700)
            L1 = Link('d', 0.1452, 'a', -0.146, 'alpha', -pi/2);
            L2 = Link('d', 0,     'a', 0.350, 'alpha', 0);
            L3 = Link('d', 0,     'a', 0.100, 'alpha', -pi/2);
            L4 = Link('d', 0.350, 'a', 0,     'alpha', pi/2);
            L5 = Link('d', 0,     'a', 0,     'alpha', -pi/2);
            L6 = Link('d', 0.100, 'a', 0,     'alpha', 0);
            
            % Incorporate joint limits
            L1.qlim = [-270 270]*pi/180;        % Datasheet TM5-700 (+/-270)    % Tested -180 180
            L2.qlim = [-180 180]*pi/180;        % Datasheet TM5-700 (+/-180)    % Tested -180 -45
            L3.qlim = [-155 155]*pi/180;          % Datasheet TM5-700 (+/-155)    % Tested -90 70
            L4.qlim = [-180 180]*pi/180;        % Datasheet TM5-700 (+/-180)    % Tested -180 180
            L5.qlim = [-180 180]*pi/180;          % Datasheet TM5-700 (+/-180)    % Tested -90 90
            L6.qlim = [-225 225]*pi/180;        % Datasheet TM5-700 (+/-225)    % Tested -180 180
        
            %L1.offset = pi/2;
            %L2.offset = -pi/2;
            %L3.offset = -pi/2;
            %L4.offset = -pi/2;
            %L5.offset = -pi/2;
            %L6.offset = -pi/2;
            
            % Create the SerialLink robot model
            robot = SerialLink([L1 L2 L3 L4 L5 L6], 'name', 'Omron TM5');

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
            hold on;
            feederRobot = OmronTM5();
                % Move base to 0,0,0 for test
                    OneByThreeCartMat = [0,1,0];                        % Translate base to desired coordinate
                    feederRobot.moveBaseOmron(OneByThreeCartMat);
            feederRobot.teachOmron();