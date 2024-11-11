classdef WelderRobot < RobotBaseClass
    %% WelderRobot
    properties(Access = public)              
        plyFileNameStem = 'WelderRobot';
    end
    
    methods
%% Define robot Function 
        function self = WelderRobot(baseTr)
			self.CreateModel();
            if nargin < 1			
				baseTr = eye(4);				
            end
            self.model.base = self.model.base.T * baseTr;
            self.PlotAndColourRobot();  
            
            % Teach() can be used to interact with Welder Robot
                % self.model.teach();
        end

%% Create the robot model
        function CreateModel(self)

            L1 = Link('d', 0.16, 'a', 0, 'alpha', -pi/2);
            L2 = Link('d', 0.12,     'a', 0.4, 'alpha', pi);
            L3 = Link('d', 0.12,     'a', 0.4, 'alpha', pi);
            L4 = Link('d', 0.13, 'a', 0,     'alpha', pi/2);
            L5 = Link('d', 0.12,     'a', 0,     'alpha', pi/2);
            L6 = Link('d', 0.13, 'a', 0,     'alpha', 0);
            L7 = Link('d', 0.230, 'a', 0,     'alpha', 0);
            
            % Incorporate joint limits
            L1.qlim = [-270 270]*pi/180;        % Datasheet     % Tested 
            L2.qlim = [-90 90]*pi/180;        % Datasheet     % Tested 
            L3.qlim = [-155 155]*pi/180;          % Datasheet     % Tested 
            L4.qlim = [-120 120]*pi/180;        % Datasheet     % Tested 
            L5.qlim = [-180 180]*pi/180;          % Datasheet     % Tested 
            L6.qlim = [0 0]*pi/180;        % Datasheet     % Tested 
            L7.qlim = [0 0]*pi/180;        
        
            L1.offset = pi/2;
            L2.offset = -pi/2;
            L3.offset = 0;
            L4.offset = pi/2;
            L5.offset = 0;
            L6.offset = 0;
            L7.offset = 0;
            
            self.model = SerialLink([L1 L2 L3 L4 L5 L6 L7], 'name', 'Welder Robot');
        end
    %%  Teach function
        function OmronTeach(self, q)
            if nargin < 2
                    q = [0 0 0 0 0 0 0];
            end
            self.model.teach(q);
        end

    %%  Fkine function
        function OmronFkine(self,q)
            if nargin < 2
                    q = [0 0 0 0 0 0 0];
            end
            OmronPose = self.model.fkine(q) %#ok<NOPRT,NASGU>
        end

    %% Move welder robot end effector to specific cartesian in straight line
    function WelderMoveToCartesian(self,Cartesian,Roll,Pitch,Yaw)
            % Ensure values are provided
                if nargin < 2
                    Cartesian = [-0.5, 0, 0];    % Default state
                end
                if nargin < 3
                    Roll = 90;
                end
                if nargin < 4
                    Pitch = 0;
                end
                if nargin < 5
                    Yaw = 180;
                end
            % Get initial pose
                initialq = self.model.getpos;
            % Get final transform
                % finalTr = transl(Cartesian) * rpy2tr(Roll, Pitch, Yaw, 'deg');   % Note: 90, 0, 180 Faces positive Y direction

            % Calculate the straight-line path in Cartesian space
                steps = 15;
                s = linspace(0, 1, steps);                      % Linear space for interpolation
                cartesianPath = nan(steps, 3);                  % Initialise path matrix
                % Calculate intermediate points along straight line
                    for i = 1:steps
                        cartesianPoint = (1 - s(i)) * self.model.fkine(initialq).t' + s(i) * Cartesian;
                        cartesianPath(i, :) = cartesianPoint;
                    end
            % Display movement to final position
                for i = 2:steps
                    % Get initial pose
                        initialq = self.model.getpos;
                    % Get the joint angles corresponding to the current Cartesian position
                        desiredTr = transl(cartesianPath(i, :)) * rpy2tr(Roll, Pitch, Yaw, 'deg');
                        desiredq = self.model.ikcon(desiredTr, initialq);
                    self.model.animate(desiredq);
                    drawnow();
                end
            pause(0.5);
    end
    %% Move Welder function - Welder Moves By itself - Using Final Q input
    function WelderMove_FinalQInput(self,FinalQ)
            % 
                if nargin < 2
                    FinalQ = [0 0 0 0 0 0 0];    % Default state
                end
            % Get initial pos
                initialq = self.model.getpos;
            % Calculate using Trapezoidal Velocity Profile
                steps = 50;
                s = lspb(0,1,steps);
                qMatrix = nan(steps, 7);        % 50 by 7 matrix with NaN
                for i = 1:steps
                    qMatrix(i,:) = ((1-s(i))*initialq) + (s(i)*FinalQ);
                end
            % Animate movement to pickup zone
            for i = 1:6:steps
                self.model.animate(qMatrix(i,:));
                drawnow();
                pause(0.1);
            end
            pause(0.5);
    end
    %% Move Welder function - Omron Moves By itself - Using Final Q input
        function Welder_qMatrix = Welder_Move(self,FinalQ)
                % 
                    if nargin < 2
                        FinalQ = [0 0 0 0 0 0 0];    % Default state
                    end
                % Get initial pos
                    initialq = self.model.getpos;
                % Calculate using Trapezoidal Velocity Profile
                    steps = 50;
                    s = lspb(0,1,steps);
                    Welder_qMatrix = nan(steps, 7);        % 50 by 7 matrix with NaN
                    for i = 1:steps
                        Welder_qMatrix(i,:) = ((1-s(i))*initialq) + (s(i)*FinalQ);
                    end
        end
    end
end