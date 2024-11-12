classdef OmronTM5700_V2 < RobotBaseClass
    %% OmronTM5700 robot class
    % This class creates an Omron TM5 700 robot arm with a suction cup end 
    % effector. Constructor creates the robot arm at a given base
    % transform. 
    properties(Access = public)              
        plyFileNameStem = 'OmronTM5700';
        % steelPlate = SteelPlate(1, -0.35, 0, 0.5);
        % steelPlate
    end
    
    methods
%% Define robot Function 
        % Class constructor
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
% Creates omron robot model - Defines DH Parameters based on online
% datasheet. Qlims are defined based on visual simulation testing. 
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
    %%  Teach function - For testing of Omron
        function OmronTeach(self, q)
            if nargin < 2
                    q = [0 0 0 0 0 0 0];
            end
            self.model.teach(q);
        end

    %%  Fkine function - Runs fkine to generate end effector pose for given joint state for Omron TM5 700
        function OmronPose = OmronFkine(self,q)
            if nargin < 2
                    q = [0 0 0 0 0 0 0];
            end
            OmronPose = self.model.fkine(q); 
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