% OmronTM5.m

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

            % Define the DH parameters for Omron TM5
            % Note: Replace these parameters with the actual ones if available

            % % Use one set of DH parameters, not both
            % % First set:
            % L1 = Link('d', 0.225, 'a', 0,     'alpha', -pi/2);
            % L2 = Link('d', 0,     'a', 0.350, 'alpha', 0);
            % L3 = Link('d', 0,     'a', 0.100, 'alpha', -pi/2);
            % L4 = Link('d', 0.350, 'a', 0,     'alpha', pi/2);
            % L5 = Link('d', 0,     'a', 0,     'alpha', -pi/2);
            % L6 = Link('d', 0.100, 'a', 0,     'alpha', 0);
            % 
            % % Alternatively, if you prefer the second set, comment out the first set
            % % L1 = Link('d', 0.2, 'a', 0, 'alpha', -pi/2);
            % % L2 = Link('d', 0, 'a', 0.3, 'alpha', 0);
            % % L3 = Link('d', 0, 'a', 0.2, 'alpha', -pi/2);
            % % L4 = Link('d', 0.4, 'a', 0, 'alpha', pi/2);
            % % L5 = Link('d', 0, 'a', 0, 'alpha', -pi/2);
            % % L6 = Link('d', 0.1, 'a', 0, 'alpha', 0);
            % 
            % % Create the SerialLink robot model
            % self.robot = SerialLink([L1 L2 L3 L4 L5 L6], 'name', 'Omron TM5');
        end
        
        %% CREATE OMRON MODEL (DH PARAMETERS)
        function CreateOmron(self)   
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
            self.robot = SerialLink([L1 L2 L3 L4 L5 L6], 'name', 'Omron TM5');
        end

        %% PLOT ROBOT AT Q
        function plotRobot(self, q)
            % Plot the robot at configuration q
            if nargin < 2 || isempty(q)
                q = zeros(1,6); % Default to zero position
            end
            % Plot the robot
            self.robot.plot(q, 'workspace', [-5 5 -5 5 0 5], ...
                'nojoints', 'noname', 'noshadow', 'nowrist', 'delay', 0);
        end

        %% OMRON MOVEMENT CLASS FUNCTION - Move the robot's end-effector to a specified 3D point
        function moveToPoint(self, point)
            if nargin < 2 || isempty(point)
                point = [1, 1, 1]; % Default to zero position
            end
            % Get current pose (Initial joint configuration)
                q0 = self.robot.getpos;
            % Get points end-effector translation matrix
                T = transl(point) * rpy2tr(0, 180, 180, 'deg');              % Desired end-effector position always facing down
            % Calculate required joint states using inverse kinematics
                q_sol = self.robot.ikcon(T, q0);
            % Calculate movement using Trapezoidal Velocity Profile
                steps = 50;
                s = lspb(0,1,steps);
                qMatrix = nan(steps, 6);        % 50 by 6 matrix with NaN
                for i = 1:steps
                    qMatrix(i,:) = ((1-s(i))*q0) + (s(i)*q_sol);
                end
             % Animate movement to point location
                for i = 1:1:steps
                   self.robot.animate(qMatrix(i,:));
                   drawnow();
                end
            % self.robot.plot(q_sol, 'workspace', [-5 5 -5 5 0 5], ...
            %     'nojoints', 'noname', 'noshadow', 'nowrist', 'delay', 0);
        end
        
        %% OMRON TEACH FUNCTION
        function teachOmron(self,q)
            if nargin < 2 || isempty(q)
                %q = [0, deg2rad(-90), deg2rad(-90), 0, 0, 0]; % Default to zero position
                q = [0, 0, 0, 0, 0, 0]; % Default to zero position
            end
            % Call teach function
                self.robot.teach(q);
        end

        %% OMRON fkine FUNCTION
        function fkineOmron(self, q)
            self.robot.fkine(q);
        end

        %% OMRON Move base FUNCTION
        function moveBaseOmron(self, OnebyThreeCartMat)
            self.robot.base = self.robot.base.T * eye(4) * transl(OnebyThreeCartMat);
        end
    end
end
