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
                self.model.teach();
        end

%% Create the robot model
        function CreateModel(self)

            L1 = Link('d', 0.16, 'a', 0, 'alpha', -pi/2);
            L2 = Link('d', 0.16,     'a', 0.35, 'alpha', pi);
            L3 = Link('d', 0.16,     'a', 0.3, 'alpha', pi);
            L4 = Link('d', 0.16, 'a', 0,     'alpha', pi/2);
            L5 = Link('d', 0.2,     'a', 0,     'alpha', pi/2);
            L6 = Link('d', 0.16, 'a', 0,     'alpha', 0);
            L7 = Link('d', 0.1, 'a', 0,     'alpha', 0);
            
            % Incorporate joint limits
            L1.qlim = [-270 270]*pi/180;        % Datasheet     % Tested 
            L2.qlim = [-90 90]*pi/180;        % Datasheet     % Tested 
            L3.qlim = [-90 90]*pi/180;          % Datasheet     % Tested 
            L4.qlim = [-90 180]*pi/180;        % Datasheet     % Tested 
            L5.qlim = [-90 90]*pi/180;          % Datasheet     % Tested 
            L6.qlim = [-225 225]*pi/180;        % Datasheet     % Tested 
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

    %% Move Omron function
    function OmronMoveToCartesian(self,FinalCartesian)
            % 
            if nargin < 2
                FinalCartesian = [-0.5, 0, 0];    % Default state
            end
            % Get initial pos
                initialq = self.model.getpos;
            % Get final transform
                finalTr = transl(FinalCartesian) * rpy2tr(0, 180, 180, 'deg');
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
                self.model.animate(qMatrix(i,:));
                drawnow();
            end
        end
    end
end