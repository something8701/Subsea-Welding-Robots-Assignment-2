classdef OmronTM5700 < RobotBaseClass
    %% OmronTM5700
    properties(Access = public)              
        plyFileNameStem = 'OmronTM5700';
        steelPlate; 
    end
    
    methods
%% Define robot Function 
        function self = OmronTM5700(baseTr,Case)
			self.CreateModel();
            if nargin < 1			
				baseTr = eye(4);				
            end
            if nargin < 2		
				Case = 1;
            end
            self.model.base = self.model.base.T * baseTr;
            self.PlotAndColourRobot();  
            % This is for testing - only generates Steel Plate
                if Case == 2
                    steelPlate = SteelPlate(1, -0.35, 0, 0.5);
                end

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
        function OmronFkine(self,q)
            if nargin < 2
                    q = [0 0 0 0 0 0 0];
            end
            OmronPose = self.model.fkine(q) %#ok<NOPRT,NASGU>
        end
    %% Move Omron function - Omron Moves By itself - Using Final Q input
        function Omron_MoveToq(self,FinalQ)
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
                    % Slow it down for testing
                        pause(0.1);
                    self.model.animate(qMatrix(i,:));
                    drawnow();
                end
                pause(0.5);
        end
    %% Move Omron function - With Steel Plate attached - Using Final Q input
        function OmronAndSteel_MoveToq(self,FinalQ)
            % In case no argument is given
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
                % Slow it down for testing
                    pause(0.1);
                self.model.animate(qMatrix(i,:));
                % run fkine once and store
                    % EndEffectorTr = self.model.fkine([qMatrix(i,:)]);
                    % EndEffectorTr = EndEffectorTr.T;
                % Move steel to end effector pose
                    % Place the steel plate at its final position by updating the base transformation
                    self.steelPlate.brickModel{1}.base = self.model.fkine(self.model.getpos()).T * transl(0, 0, 0.01);
                    %self.steelPlate.brickModel{1}.animate(0);
                drawnow();
            end
            pause(0.5);
        end
    %% Move Omron function - Facing wall
        function Omron_MoveToCartesian(self,FinalCartesian,Roll,Pitch,Yaw)
                % 
                if nargin < 2
                    FinalCartesian = [-0.5, 0, 0];    % Default state
                end
                % Get initial pos
                    initialq = self.model.getpos;
                % Get final transform
                    finalTr = transl(FinalCartesian) * rpy2tr(Roll, Pitch, Yaw, 'deg');
                % Use inverse kinematics to find q - joint angles for target coordinates. 
                    finalq = self.model.ikcon(finalTr,initialq);
                % Calculate using Trapezoidal Velocity Profile
                    steps = 35;
                    s = lspb(0,1,steps);
                    qMatrix = nan(steps, 7);        % 50 by 7 matrix with NaN
                    for i = 1:steps
                        qMatrix(i,:) = ((1-s(i))*initialq) + (s(i)*finalq);
                    end
                % Animate movement to pickup zone
                for i = 1:10:steps
                    % Slow it down for testing
                        pause(0.1);
                    self.model.animate(qMatrix(i,:));
                    drawnow();
                end
                pause(0.5);
        end
    %% Move Omron and steel plate move - based on cartesian input (downward orientation)
        function OmronAndSteel_MoveToCartesian(self,FinalCartesian,Roll,Pitch,Yaw)
            % 
            if nargin < 2
                FinalCartesian = [-0.5, 0, 0];    % Default state
            end
            % Get initial pos
                initialq = self.model.getpos;
            % Get final transform
                finalTr = transl(FinalCartesian) * rpy2tr(Roll, Pitch, Yaw, 'deg');
            % Use inverse kinematics to find q - joint angles for target coordinates. 
                finalq = self.model.ikcon(finalTr,initialq);
            % Calculate using Trapezoidal Velocity Profile
                steps = 50;
                s = lspb(0,1,steps);
                qMatrix = nan(steps, 7);        % 50 by 7 matrix with NaN
                for i = 1:steps
                    qMatrix(i,:) = ((1-s(i))*initialq) + (s(i)*finalq);
                end
            % Animate movement to pickup zone
            for i = 1:6:steps
                % Animate
                    self.model.animate(qMatrix(i,:));
                % run fkine once and store
                    % EndEffectorTr = self.model.fkine([qMatrix(i,:)]);
                    % EndEffectorTr = EndEffectorTr.T;
                % Move steel to end effector pose
                    % Place the steel plate at its final position by updating the base transformation
                    % steelPlate.brickModel{1}.base = self.model.fkine(self.model.getpos()).T * transl(0, 0, 0.01);
                    %self.steelPlate.brickModel{1}.animate(0);
                drawnow();
                pause(0.1);
            end
            pause(0.5);
        end
    %% Move Omron function - Facing wall
        function OmronMoveBase(self,finalCartesian)
                % 
                if nargin < 2
                    finalCartesian = [0, 0, 0];    % Default base
                end
                % Get initial pose
                    initialq = self.model.getpos;
                % Get initial base coordinates
                    matrix = self.model.base.T;
                    initialBaseCartesian = [matrix(1:3,4)'];
                % Calculate the straight-line path in Cartesian space
                    steps = 50;
                    s = linspace(0, 1, steps);                      % Linear space for interpolation
                    cartesianPath = nan(steps, 3);                  % Initialise path matrix
                % Calculate intermediate points along straight line
                    for i = 1:steps
                        cartesianPoint = (1 - s(i)) * initialBaseCartesian + s(i) * finalCartesian;
                        cartesianPath(i, :) = cartesianPoint;
                    end
                % Animate movement to pickup zone
                for i = 2:steps
                    % set new base
                        self.model.base = transl(cartesianPath(i, :));
                    % plot
                        self.model.animate(initialq);
                    drawnow();
                end
                pause(0.5);
        end
    end
end