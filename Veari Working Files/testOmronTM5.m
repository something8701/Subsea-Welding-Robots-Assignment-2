classdef testOmronTM5 < handle
%#ok<*NASGU>
%#ok<*NOPRT>
%#ok<*TRYNC>
    properties
        feederRobot % Property to hold the OmronTM5 instance
    end

    methods 
		function self = testOmronTM5()
			clf
			clc
			input('Press enter to begin')
            self.Initialise();
            %self.Test1(); 
            %self.Test2();
            %self.Test3();
		end
	end
    
    methods(Static)
        %% Initialise
            function Initialise()
                % Create 3D surface plot of floor. 
                    surf([-1.0,-1.0;1.0,1.0] ...                % X-coordinates of surface
                        ,[-1.0,1.0;-1.0,1.0] ...                % Y-coordinates of surface
                        ,[0,0;0,0] ...                          % Z-coordinates of surface (flat plane)
                        ,'CData',imread('concrete.jpg') ...
                        ,'FaceColor','texturemap');
                    camlight;                                   % Run this once
                    axis equal;                                 % Equal scaling for all axes
                    % Set the view to 1-by-1-by-1
                        xlim([-0.8 0.8]); % Set limits for x-axis
                        ylim([-0.8 0.8]); % Set limits for y-axis
                        zlim([-0.2 1]); % Set limits for z-axis
                    hold on;
                % Initialize and Plot Robots
                    feederRobot = OmronTM5();
                        % Move base to 0,0,0 for test
                            OneByThreeCartMat = [0,1,0];                        % Translate base to desired coordinate
                            feederRobot.moveBaseOmron(OneByThreeCartMat);
                    % Plot feederRobot - neutral straight upward position
                        q = [0 0 0 0 0 0];
                        feederRobot.plotRobot(q);
                    input('Press enter: Display highest reach')
                        feederRobot.fkineOmron(q)   % Display highest reach transform
                    input('Press enter: Move in square motion')
                        p1 = [-0.5, 0, 0.1452];
                        %pDefault = [-0.2354, 0, 0.8917];
                        p3 = [0, -0.5, 0.1452];

                        p5 = [0.5, 0, 0.1452];

                        p7 = [0, 0.5, 0.1452];

                        feederRobot.moveToPoint(p1);

                        feederRobot.moveToPoint(p3);

                        feederRobot.moveToPoint(p5);

                        feederRobot.moveToPoint(p7);

                    % Input('Press enter: Teach()')
                    % Teach Robot
                        %feederRobot.teachOmron();
            end
        %% Test Omron Teach()
            function Test1()
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
            end
        %% Test Omron Bounds / Limits
            function Test2()
                
            end
        %% Test Omron Movement
            function Test3()    

            end
    end
end