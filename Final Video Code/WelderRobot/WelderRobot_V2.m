classdef WelderRobot_V2 < RobotBaseClass
    %% WelderRobot
    properties(Access = public)              
        plyFileNameStem = 'WelderRobot';
    end
    
    methods
%% Define robot Function 
        function self = WelderRobot_V2(baseTr)
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
        function WelderPose = WelderFkine(self,q)
            if nargin < 2
                    q = [0 0 0 0 0 0 0];
            end
            WelderPose = self.model.fkine(q);
        end

    %% Move welder robot end effector to specific cartesian in straight line
    function WelderMoveToCartesian(self,Final_Cart,Roll,Pitch,Yaw)
            % Ensure values are provided
                if nargin < 2
                    Final_Cart = [-0.5, 0, 0];    % Default state
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
            % Steps
                Steps = 30; 
            % Get final transform
                % finalTr = transl(Cartesian) * rpy2tr(Roll, Pitch, Yaw, 'deg');   % Note: 90, 0, 180 Faces positive Y direction
            % Calculate the straight-line path in Cartesian space
                CartesianMatrix = TVP_Cartesian_Robot(self, Steps, 3, Final_Cart); 
            % Display movement to final position
                for i = 2:Steps
                    % Get initial pose
                        initialq = self.model.getpos;
                    % Get the joint angles corresponding to the current Cartesian position
                        desiredTr = transl(CartesianMatrix(i, :)) * rpy2tr(Roll, Pitch, Yaw, 'deg');
                        desiredq = self.model.ikcon(desiredTr, initialq);
                    self.model.animate(desiredq);
                    drawnow();
                end
            pause(0.5);
    end


        %% Trapezoidal Velocity Profile - Initial and Final Joint State
        function qMatrix = TVP_q(self, Steps, Finalq)
                % Get initial pos
                    Initialq = self.model.getpos;
                % Calculate using Trapezoidal Velocity Profile
                    s = lspb(0,1,Steps);
                    qMatrix = nan(Steps, 7);        % 50 by 7 matrix with NaN
                    for i = 1:Steps
                        qMatrix(i,:) = ((1-s(i))*Initialq) + (s(i)*Finalq);
                    end
        end
        %% Trapezoidal Velocity Profile - Straight Line Cartesian Movement - Base Movement
        function CartesianMatrix = TVP_Cartesian_Base(self, Steps, Matrix_Columns, Final_Cart)
            % Get initial base coordinates
                    matrix = self.model.base.T;
                    Initial_Cart = matrix(1:3,4)';    
            % Calculate using Trapezoidal Velocity Profile
                    s = linspace(0, 1, Steps);                                      % Linear space for interpolation
                    CartesianMatrix = nan(Steps, Matrix_Columns);                   % Initialise path matrix
                    for i = 1:Steps
                        CartesianMatrix(i,:) = (1 - s(i)) * Initial_Cart + s(i) * Final_Cart;
                    end
        end
        %% Trapezoidal Velocity Profile - Straight Line Cartesian Movement - Robot Arm Movement
        function CartesianMatrix = TVP_Cartesian_Robot(self, Steps, Matrix_Columns, Final_Cart)
            % Get initial pose
                Initialq = self.model.getpos;    
            % Calculate using Trapezoidal Velocity Profile
                    s = linspace(0, 1, Steps);                                      % Linear space for interpolation
                    CartesianMatrix = nan(Steps, Matrix_Columns);                   % Initialise path matrix
                    for i = 1:Steps
                        CartesianMatrix(i,:) = (1 - s(i)) * self.model.fkine(Initialq).t' + s(i) * Final_Cart;
                    end
        end
    end
end