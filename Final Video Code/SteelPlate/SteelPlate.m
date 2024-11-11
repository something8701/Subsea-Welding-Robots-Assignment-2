%% Vicky Choy 14273611 & Vearinama Kila 12582336
classdef SteelPlate < handle
    %% Creates user defined number of plates in a grid    
    %#ok<*TRYNC>    

    properties (Constant)
        maxHeight = 2; % Maximum height for the workspace
    end
    
    properties
        numPlates = 1;               % Default number of plates (updated name)
        plateModel;                   % A grid structure of plate models
        plotSize = [2, 2];            % Plot size in meters
        workspaceDimensions;          % Dimensions of the workspace
    end

    methods
        %% Constructor
        % function that initialises the number of plate
        % If a number of plates is provided, it updates default number
        function self = SteelPlate(numPlates,X,Y,Z)
            if nargin < 4
                Z = 0.5;
            end
            if nargin < 3
                Y = 0;
            end
            if nargin < 2
                X = -0.35;
            end
            if nargin > 0
                self.numPlates = numPlates; % Set plate count if provided 
            end
            % Define workspace dimensions based on plot size
            % Workspace is centered at (0,0), X and Y limits based on plot size
            self.workspaceDimensions = [-self.plotSize(1)/2, self.plotSize(1)/2, ...
                                        -self.plotSize(2)/2, self.plotSize(2)/2, ...
                                        0, self.maxHeight];
            % Initialise plate
            self.initialisePlate(X,Y,Z);
        end

        %% Method to initialize the plate models
        function initialisePlate(self,X,Y,Z)
            for i = 1:self.numPlates
                % Create a plate model for each plate
                self.plateModel{i} = self.GetPlateModel(['SteelPlate.PLY', num2str(i)]);
                % Generate the pose of plate in a grid iteratively
                    basePose = SE3(SE2(0, 0, 0));
                self.plateModel{i}.base = basePose.T * transl(X, Y, Z);                             % Adjust the base as required
                % Plot the 3D model of the plate
                    plot3d(self.plateModel{i}, 0, 'workspace', self.workspaceDimensions,'view', [-30, 30], 'delay', 0, 'noarrow', 'nowrist');
                % Hold on after the first plot for subsequent bricks
                if i == 1
                    hold on;
                end
            end
        end

        %% Method to move Steel Plate
        function moveSteelPlate(self,EndEffectorTr)
                % Generate the pose of plate in a grid iteratively
                    basePose = SE3(SE2(0, 0, 0));
                self.plateModel{1}.base = basePose.T * EndEffectorTr;
                % self.plateModel{1}.base = basePose.T * EndEffectorTr.T;                             % Adjust the base as required
                % Plot the 3D model of the plate
                plot3d(self.plateModel{1}, 0, 'workspace', self.workspaceDimensions,'view', [-30, 30], 'delay', 0, 'noarrow', 'nowrist');
        end
    end

    methods (Static)
        %% Create model in MATLAB from PLY file
        function model = GetPlateModel(name)
            % Static method creates a plate model using 3D ply file
            % plate represented as a single link robot
            if nargin < 1
                name = 'Plate';
            end
            % Load the 3D model from the PLY file
            [faceData, vertexData] = plyread('SteelPlate.PLY', 'tri');
            % Define a single link to represent the plate
            link1 = Link('alpha', pi, 'a', 0, 'd', 0.01, 'offset', 0);
            model = SerialLink(link1, 'name', name);
            % Assign the 3D data to the robot model's link (Link 1)
            model.faces = {[], faceData}; % Faces for Link 1
            model.points = {[], vertexData}; % Vertices for Link 1
        end
    end
end