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
                %% Initialize and Plot Robots
                    % Initialize the OmronTM5
                        feederRobot = OmronTM5();
                    % Plot feederRobot
                        feederRobot.plotRobot();
                    input('Press enter: Move in square motion')
                        p1 = [0, -1, 1];
                        p2 = [0, -1, 2];
                        p3 = [0, 0, 2];
                        p4 = [0, 0, 1];
                        p5 = [0, -1, 1];
                        feederRobot.moveToPoint(p1);
                        feederRobot.moveToPoint(p2);
                        feederRobot.moveToPoint(p3);
                        feederRobot.moveToPoint(p4);
                        feederRobot.moveToPoint(p5);
                    input('Press enter: Teach()')
                    % Teach Robot
                        feederRobot.teachOmron();
            end
        %% Test Omron Teach
            function Test1()
                feederRobot.teachOmron();
            end
        %% Test Omron Bounds / Limits
            function Test2()
                
            end
        %% Test Omron Movement
            function Test3()    
                p1 = [0, -0.5, 0.5];
                p2 = [0, -0.5, 1];
                p3 = [0, 0, 1];
                p4 = [0, 0, 0.5];
                p5 = [0, -0.5, 0.5];
                feederRobot.moveToPoint(p1);
                feederRobot.moveToPoint(p2);
                feederRobot.moveToPoint(p3);
                feederRobot.moveToPoint(p4);
                feederRobot.moveToPoint(p5);
            end
    end
end