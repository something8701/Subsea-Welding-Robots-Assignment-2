classdef OmronTM5700_V2 < RobotBaseClass
    %% OmronTM5700
    properties(Access = public)              
        plyFileNameStem = 'OmronTM5700';
        % steelPlate = SteelPlate(1, -0.35, 0, 0.5);
        % steelPlate
    end
    
    methods
%% Define robot Function 
        function self = OmronTM5700_V2(baseTr)
			% Initialize the robot model
            self.CreateModel();
            
            % Set base transform
            if nargin < 1
                baseTr = eye(4);				
            end
            self.model.base = SE3(self.model.base.T * baseTr); % Ensure compatibility with SE3
            self.PlotAndColourRobot();  

            % Teach() can be used to interact with OmronTM5
                % self.model.teach();
        end

%% Create the robot model
        function CreateModel(self)

            L1 = Link('d', 0.1452, 'a', 0, 'alpha', -pi/2);
            L2 = Link('d', 0.146,     'a', 0.329, 'alpha', pi);
            L3 = Link('d', 0.1297,     'a', 0.3115, 'alpha', pi);
            L4 = Link('d', 0.106, 'a', 0,     'alpha', pi/2);
            L5 = Link('d', 0.106,     'a', 0,     'alpha', -pi/2);
            L6 = Link('d', 0.11315, 'a', 0,     'alpha', 0);
            L7 = Link('d', 0.1092, 'a', 0,     'alpha', 0);
            
            % Incorporate joint limits
            L1.qlim = [-270 270]*pi/180;        % Datasheet TM5-700 (+/-270)    % Tested -180 180
            L2.qlim = [-90 90]*pi/180;        % Datasheet TM5-700 (+/-180)    % Tested -90 90
            L3.qlim = [-155 155]*pi/180;          % Datasheet TM5-700 (+/-155)    % Tested -90 90
            L4.qlim = [-180 180]*pi/180;        % Datasheet TM5-700 (+/-180)    % Tested -180 180
            L5.qlim = [-180 180]*pi/180;          % Datasheet TM5-700 (+/-180)    % Tested -90 90
            L6.qlim = [-225 225]*pi/180;        % Datasheet TM5-700 (+/-225)    % Tested -180 180
            L7.qlim = [0 0]*pi/180;        
        
            L1.offset = pi/2;
            L2.offset = -pi/2;
            L3.offset = 0;
            L4.offset = pi/2;
            L5.offset = 0;
            L6.offset = 0;
            L7.offset = 0;
            
            self.model = SerialLink([L1 L2 L3 L4 L5 L6 L7], 'name', 'Omron TM5');
        end
    %%  Teach function
        function OmronTeach(self, q)
            if nargin < 2
                    q = [0 0 0 0 0 0 0];
            end
            self.model.teach(q);
        end

    %%  Fkine function
        function OmronPose = OmronFkine(self,q)
            if nargin < 2
                    q = [0 0 0 0 0 0 0];
            end
            OmronPose = self.model.fkine(q); 
        end
    %% Move Omron function - With Steel Plate attached - Using Final Q input
        function OmronAndSteel_MoveToq(self,Finalq)
            % In case no argument is given
                if nargin < 2
                    Finalq = [0 0 0 0 0 0 0];    % Default state
                end
            % Initialise Step Count
                Steps = 50;
            % Calculate using Trapezoidal Velocity Profile
                qMatrix = self.TVP_q(Steps, Finalq);
            % Animate movement to pickup zone
            for i = 2:6:Steps
                self.model.animate(qMatrix(i,:));
                % run fkine once and store
                    % EndEffectorTr = self.model.fkine([qMatrix(i,:)]);
                    %EndEffectorTr = EndEffectorTr.T;
                % Move steel to end effector pose
                    % Place the steel plate at its final position by updating the base transformation
                        % self.steelPlate.moveSteelPlate(EndEffectorTr);
                drawnow();
                % Slow it down for testing
                    % pause(0.1);
            end
            pause(0.5);
        end
    %% Move Omron function - Facing wall
        function Omron_MoveToCartesian(self,Final_Cart,Roll,Pitch,Yaw)
                % Ensure values are provided
                if nargin < 2
                    Final_Cart = [0, 0, 0];    % Default state
                end
                if nargin < 3
                    Roll = 0;
                end
                if nargin < 4
                    Pitch = 0;
                end
                if nargin < 5
                    Yaw = 0;
                end
            % Initialise Step Count
                Steps = 50;
            % Calculate the straight-line path in Cartesian space
                CartesianMatrix = self.TVP_Cartesian_Robot(Steps, 3, Final_Cart); 
            % Display movement to final position
                for i = 2:6:Steps
                    % Get initial pose
                        initialq = self.model.getpos;
                    % Get the joint angles corresponding to the current Cartesian position
                        desiredTr = transl(CartesianMatrix(i, :)) * rpy2tr(Roll, Pitch, Yaw, 'deg');
                        desiredq = self.model.ikcon(desiredTr, initialq);
                    self.model.animate(desiredq);
                    drawnow();
                    % Slow it down for testing
                        % pause(0.1);
                end
        end
    %% Move Omron and steel plate move - based on cartesian input (downward orientation)
        function OmronAndSteel_MoveToCartesian(self,Final_Cart,Roll,Pitch,Yaw)
            % Ensure values are provided
                if nargin < 2
                    Final_Cart = [0, 0, 0];    % Default state
                end
                if nargin < 3
                    Roll = 0;
                end
                if nargin < 4
                    Pitch = 0;
                end
                if nargin < 5
                    Yaw = 0;
                end
           % Initialise Step Count
                Steps = 50;
           % Calculate the straight-line path in Cartesian space
                CartesianMatrix = self.TVP_Cartesian_Robot(Steps, 3, Final_Cart); 
                % % Calculate intermediate points for Roll, Pitch and Yaw
                %     initialTr = initialTr.T;
                %     rotationMatrix = initialTr(1:3,1:3);
                %         initRoll = atan2(rotationMatrix(3,2),rotationMatrix(3,3));
                %         initPitch = asin(-rotationMatrix(3,1));
                %         initYaw = atan2(rotationMatrix(2,1),rotationMatrix(1,1));
                %         initialRot = [initRoll, initPitch, initYaw];
                %     for i = 1:steps
                %         rotationPoint = (1 - s(i)) * initialRot + s(i) * [Roll, Pitch, Yaw];
                %         rotationPath(i, :) = rotationPoint;
                %     end
            % Display movement to final position
                for i = 2:6:Steps
                    % Get initial pose
                        initialq = self.model.getpos;
                    % Get the joint angles corresponding to the current Cartesian position
                        desiredTr = transl(CartesianMatrix(i, :)) * rpy2tr(Roll, Pitch, Yaw, 'deg');
                        % desiredTr = desiredTr.T;
                        desiredq = self.model.ikcon(desiredTr, initialq);
                    self.model.animate(desiredq);
                    % run fkine once and store
                        % EndEffectorTr = self.model.fkine(desiredq);
                        %EndEffectorTr = EndEffectorTr.T;
                    % Move steel to end effector pose
                        % Place the steel plate at its final position by updating the base transformation
                            % self.steelPlate.moveSteelPlate(EndEffectorTr);
                    drawnow();
                    % Slow it down for testing
                        % pause(0.1);
                end
        end
    %% Move Omron function - Move Omron Base
        function OmronMoveBase(self,Steps, Final_Cart)
                % 
                if nargin < 2
                    Final_Cart = [0, 0, 0];    % Default base
                end
                % Get initial pose
                    initialq = self.model.getpos;
                % Calculate the straight-line path in Cartesian space
                    CartesianMatrix = self.TVP_Cartesian_Base(Steps, 3, Final_Cart); 
                % Animate movement to pickup zone
                for i = 2:6:Steps
                    % set new base
                        self.model.base = transl(CartesianMatrix(i, :));
                    % plot
                        self.model.animate(initialq);
                    drawnow();
                    % Slow it down for testing
                        % pause(0.1);
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