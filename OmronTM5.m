classdef OmronTM5 < handle
    properties
        robot % SerialLink object representing the robot
    end

    methods
        function self = OmronTM5(baseTr)
            self.CreateOmron();
            if nargin < 1			
				baseTr = eye(4);				
            end
            self.robot.base = self.robot.base.T * baseTr * transl(0, -1, 0);    % Adjust as needed
        end
        
        function CreateOmron(self)
            % Create the Omron TM5 (Assume TM5-700)
            L1 = Link('d', 0.1452, 'a', 0, 'alpha', -pi/2);
            L2 = Link('d', 0.146,     'a', 0.329, 'alpha', 0);
            L3 = Link('d', -0.1297,     'a', 0.3115, 'alpha', 0);
            L4 = Link('d', 0.106, 'a', 0,     'alpha', pi/2);
            L5 = Link('d', 0.106,     'a', 0,     'alpha', -pi/2);
            L6 = Link('d', 0.11315, 'a', 0,     'alpha', 0);
            
            % Joint limits
            L1.qlim = [-270 270]*pi/180;
            L2.qlim = [-180 180]*pi/180;
            L3.qlim = [-155 155]*pi/180;
            L4.qlim = [-180 180]*pi/180;
            L5.qlim = [-180 180]*pi/180;
            L6.qlim = [-225 225]*pi/180;
            
            % Offsets
            L1.offset = pi/2;
            L2.offset = -pi/2;
            L3.offset = 0;
            L4.offset = pi/2;
            L5.offset = 0;
            L6.offset = 0;
            
            % Create the SerialLink robot model
            self.robot = SerialLink([L1 L2 L3 L4 L5 L6], 'name', 'Omron TM5');
        end

        function plotRobot(self, q)
            if nargin < 2 || isempty(q)
                q = zeros(1,6);
            end
            self.robot.plot(q, 'workspace', [-5 5 -5 5 0 5], 'nojoints', 'noname', 'noshadow', 'nowrist', 'delay', 0);
        end
    end
end