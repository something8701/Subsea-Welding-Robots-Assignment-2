classdef UR3e < RobotBaseClass
    %% UR3e
    properties(Access = public)              
        plyFileNameStem = 'UR3e';
    end
    
    methods
%% Define robot Function 
        function self = UR3e(baseTr)
			self.CreateModel();
            if nargin < 1			
				baseTr = eye(4);				
            end
            self.model.base = self.model.base.T * baseTr;
            self.PlotAndColourRobot();         
        end

%% Create the robot model
        function CreateModel(self)   
            % % Create the UR3e model
            % link(1) = Link('d',0.15185,'a',0,'alpha',pi/2,'qlim',deg2rad([-360 360]), 'offset',0);
            % link(2) = Link('d',0,'a',-0.24355,'alpha',0,'qlim', deg2rad([-360 360]), 'offset',0);
            % link(3) = Link('d',0,'a',-0.2132,'alpha',0,'qlim', deg2rad([-360 360]), 'offset', 0);
            % link(4) = Link('d',0.13105,'a',0,'alpha',pi/2,'qlim',deg2rad([-360 360]),'offset', 0);
            % link(5) = Link('d',0.08535,'a',0,'alpha',-pi/2,'qlim',deg2rad([-360,360]), 'offset',0);
            % link(6) = Link('d',	0.0921,'a',0,'alpha',0,'qlim',deg2rad([-360,360]), 'offset', 0);

            % Create the UR3e model
            % link(1) = Link('d',0.15185,'a',0,'alpha',pi/2,'qlim',deg2rad([-360 360]), 'offset',0);
            % link(2) = Link('d',0,'a',-0.24355,'alpha',0,'qlim', deg2rad([-90 90]), 'offset',0);
            % link(3) = Link('d',0,'a',-0.2132,'alpha',0,'qlim', deg2rad([-125 125]), 'offset', 0);
            % link(4) = Link('d',0.13105,'a',0,'alpha',pi/2,'qlim',deg2rad([-360 360]),'offset', 0);
            % link(5) = Link('d',0.08535,'a',0,'alpha',-pi/2,'qlim',deg2rad([-360 360]), 'offset',0);
            % link(6) = Link('d',	0.0921,'a',0,'alpha',0,'qlim',deg2rad([-360 360]), 'offset', 0);

            % Create the UR3e model
            link(1) = Link('d',0.15185,'a',0,'alpha',pi/2,'qlim',deg2rad([-360 360]), 'offset',0);
            link(2) = Link('d',0,'a',-0.24355,'alpha',0,'qlim', deg2rad([-90 90]), 'offset',0);
            link(3) = Link('d',0,'a',-0.2132,'alpha',0,'qlim', deg2rad([-125 125]), 'offset', -pi/2);
            link(4) = Link('d',0.13105,'a',0,'alpha',pi/2,'qlim',deg2rad([-360 360]),'offset', 0);
            link(5) = Link('d',0.08535,'a',0,'alpha',-pi/2,'qlim',deg2rad([-360 360]), 'offset',-pi/2);
            link(6) = Link('d',	0.0921,'a',0,'alpha',0,'qlim',deg2rad([-360 360]), 'offset', 0);
            
            % Incorporate joint limits
            link(1).qlim = [-360 360]*pi/180;
            link(2).qlim = [-90 90]*pi/180;          % Limit to -55 and 0 (Original -90 to 90)
            link(3).qlim = [-125 125]*pi/180;       % Limit to -125 and 125 (Original -170 to +170)
            link(4).qlim = [-360 360]*pi/180;
            link(5).qlim = [-360 360]*pi/180;
            link(6).qlim = [-360 360]*pi/180;
            
            self.model = SerialLink(link,'name',self.name);
        end
     
    end
end