%% Vicky Choy 14273611 & Vearinama Kila 12582336
classdef SteelPlate < handle
    %% Creates user defined number of bricks in a grid    
    %#ok<*TRYNC>    

    properties (Constant)
        maxHeight = 2; % Maximum height for the workspace
    end
    
    properties
        numBricks = 1;               % Default number of bricks (updated name)
        brickModel;                   % A grid structure of brick models
        plotSize = [2, 2];            % Plot size in meters
        workspaceDimensions;          % Dimensions of the workspace
    end

    methods
        %% Constructor
        % function thatinitialises the number of bricks
        % If a number of bricks is provided, it updates default number
        function self = SteelPlate(numBricks,X,Y,Z)
            if nargin > 0
                self.numBricks = numBricks; % Set brick count if provided 
            end
            % Define workspace dimensions based on plot size
            % Workspace is centered at (0,0), X and Y limits based on plot size
            self.workspaceDimensions = [-self.plotSize(1)/2, self.plotSize(1)/2, ...
                                        -self.plotSize(2)/2, self.plotSize(2)/2, ...
                                        0, self.maxHeight];
            % Initialize bricks
            self.initializeBricks(X,Y,Z);
        end

        %% Method to initialize the brick models
        function initializeBricks(self,X,Y,Z)
            for i = 1:self.numBricks
                % Create a brick model for each brick
                self.brickModel{i} = self.GetBrickModel(['SteelPlate.PLY', num2str(i)]);
                % Generate the pose of bricks in a grid iteratively
                    basePose = SE3(SE2(X, Y, 0));
                self.brickModel{i}.base = basePose.T * transl(0, 0, Z);                             % Adjust the base as required
                % Plot the 3D model of the brick
                plot3d(self.brickModel{i}, 0, 'workspace', self.workspaceDimensions,'view', [-30, 30], 'delay', 0, 'noarrow', 'nowrist');
                % Hold on after the first plot for subsequent bricks
                if i == 1
                    hold on;
                end
            end
        end
        %% Destructor method to clean up brick models
        % function delete(self)
        %     % Delete function removes all bricks from the scene when the object is destroyed
        %     for index = 1:self.numBricks
        %         % Finds graphical objects associated to brick
        %         handles = findobj('Tag', self.brickModel{index}.name);
        %         h = get(handles, 'UserData');
        %         % Try delete the robot, wrist, link and any associated objects
        %         try delete(h.robot); end
        %         try delete(h.wrist); end
        %         try delete(h.link); end
        %         try delete(h); end
        %         try delete(handles); end
        %     end
        % end
    end

    methods (Static)
        %% Create model in MATLAB from PLY file
        function model = GetBrickModel(name)
            % Static method creates a brick model using 3D ply file
            % brick represented as a single link robot
            if nargin < 1
                name = 'Brick';
            end
            % Load the 3D model from the PLY file
            [faceData, vertexData] = plyread('SteelPlate.PLY', 'tri');
            % Define a single link to represent the brick
            link1 = Link('alpha', pi, 'a', 0, 'd', 0.01, 'offset', 0);
            model = SerialLink(link1, 'name', name);
            % Assign the 3D data to the robot model's link (Link 1)
            model.faces = {[], faceData}; % Faces for Link 1
            model.points = {[], vertexData}; % Vertices for Link 1
        end
    end
end


%SteelPlateLink0.PLY