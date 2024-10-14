classdef Environment < handle
    properties
        NX           % Size in X direction
        NY           % Size in Y direction
        NZ           % Height of the environment (Z direction)
        texture      % Texture image data for walls and ceiling
        sand         % Sand texture image data for the floor
        welderModel  % Property to store the welder model
        columnModel  % Property to store the column model
        steelTileModel % Property to store the steel tile model
    end
    
    methods
        % Constructor for the Environment class
        function self = Environment(NX, NY, NZ)
            if nargin < 1
                NX = 5; % Default size
            end
            if nargin < 2
                NY = NX; % Make the environment square if NY not provided
            end
            if nargin < 3
                NZ = 3;  % Default height
            end
            self.NX = NX;
            self.NY = NY;
            self.NZ = NZ;
            
            % Load the texture images
            self.texture = imread('Data/water.png');  % For walls and ceiling
            self.sand = imread('Data/sand.png');      % For floor

            % Initialize welderModel, columnModel, and steelTileModel as empty
            self.welderModel = [];  % Initialize welderModel
            self.columnModel = [];  % Initialize columnModel
            self.steelTileModel = [];  % Initialize steelTileModel

            % Create a new figure and plot environment when instantiated
            figure;
            hAxes = gca;  % Get current axes
            self.plotEnvironment(hAxes);
            
            % Adjust the camera view to see all walls
            view(3);      % Set 3D view
            axis equal;   % Maintain aspect ratio
            
            % Load and plot the column model
            self.loadAndPlotColumn(hAxes);  % Load the column .ply file and plot
            
            % Load and plot the steel tiles
            self.loadAndPlotSteelTiles(hAxes);  % Load the steel tiles and place them in a 3x3 grid
        end
        
        function plotEnvironment(self, hAxes)
            if nargin < 2
                hAxes = gca;
            end
            
            % Plot the floor
            x = linspace(-self.NX/2, self.NX/2, 2);
            y = linspace(-self.NY/2, self.NY/2, 2);
            [X, Y] = meshgrid(x, y);
            Z = zeros(size(X)); % Floor at Z = 0
            
            % Plot the floor with the sand texture
            surface('XData', X, 'YData', Y, 'ZData', Z, ...
                'CData', self.sand, 'FaceColor', 'texturemap', ...
                'EdgeColor', 'none', 'Parent', hAxes);

            % Plot the selected two walls
            % Wall 2: Along Y-axis at X = NX/2
            [Y_wall, Z_wall] = meshgrid(linspace(-self.NY/2, self.NY/2, 2), linspace(0, self.NZ, 2));
            X_wall = self.NX/2 * ones(size(Y_wall));
            surface('XData', X_wall, 'YData', Y_wall, 'ZData', Z_wall, ...
                'CData', self.texture, 'FaceColor', 'texturemap', ...
                'EdgeColor', 'none', 'Parent', hAxes);
            
            % Wall 4: Along X-axis at Y = NY/2
            [X_wall, Z_wall] = meshgrid(linspace(-self.NX/2, self.NX/2, 2), linspace(0, self.NZ, 2));
            Y_wall = self.NY/2 * ones(size(X_wall));
            surface('XData', X_wall, 'YData', Y_wall, 'ZData', Z_wall, ...
                'CData', self.texture, 'FaceColor', 'texturemap', ...
                'EdgeColor', 'none', 'Parent', hAxes);
            
            % Plot the ceiling
            Z_ceil = self.NZ * ones(size(X_wall));
            surface('XData', X_wall, 'YData', Y_wall, 'ZData', Z_ceil, ...
                'CData', self.texture, 'FaceColor', 'texturemap', ...
                'EdgeColor', 'none', 'Parent', hAxes);
            
            % Set the axes limits and labels
            xlim(hAxes, [-self.NX/2, self.NX/2]);
            ylim(hAxes, [-self.NY/2, self.NY/2]);
            zlim(hAxes, [0, self.NZ]);  % Set Z-axis limits from 0 to NZ
            xlabel(hAxes, 'X (m)');
            ylabel(hAxes, 'Y (m)');
            zlabel(hAxes, 'Z (m)');
            
            % Enable grid and hold the plot
            grid(hAxes, 'on');
            hold on;
        end
        
        % Method to load and plot the column
        function loadAndPlotColumn(self, hAxes)
            % Load the column PLY file as a triangulated surface
            [faces, vertices, ~] = plyread('Data/columnV2.ply', 'tri');
            
            % Scale the vertices from meters to millimeters (if needed)
            vertices = vertices * 0.0018;  % Conversion / Scaling
        
            % Rotate the column around the X-axis to make it stand vertically
            rotationMatrix = [1, 0, 0;
                              0, cosd(90), -sind(90);
                              0, sind(90), cosd(90)];  % 90-degree rotation around X-axis
            
            vertices = (rotationMatrix * vertices')';  % Apply rotation to vertices
            
            % Translate the column to press against Wall 4 (Y = NY/2)
            translationVector = [0, self.NY/2.25 - 0, 0];  % Adjust for radius (85mm)
            vertices = vertices + translationVector;  % Apply translation
            
            % Plot the column model using trisurf
            trisurf(faces, vertices(:, 1), vertices(:, 2), vertices(:, 3), ...
                'FaceColor', [0.8, 0.8, 0.8], 'EdgeColor', 'none', 'Parent', hAxes);
            
            % Optionally, adjust the appearance (e.g., lighting)
            camlight('headlight');
            lighting gouraud;
            material dull;
        end
        
        % Method to load and plot the steel tiles
        function loadAndPlotSteelTiles(self, hAxes)
            % Load the steel tile PLY file
            [faces, vertices, ~] = plyread('Data/steelTile.ply', 'tri');
            
            % Scale the vertices to 100mm (0.1m) if needed
            vertices = vertices * 0.002;  
            
            % Rotate the tiles to lie flat on the floor (rotate -90 degrees around X-axis)
            rotationMatrix = [1, 0, 0;
                              0, cosd(-90), -sind(-90);
                              0, sind(-90), cosd(-90)];
            
            vertices = (rotationMatrix * vertices')';  % Apply rotation to vertices
            
            % Define grid positions (3x3) for the steel tiles, moved closer to the column
            gridX = [-0.3, 0, 0.3];     % tile x pos
            gridY = [1.6, 1.3, 1];      % tile y pos

            
            for i = 1:length(gridX)
                for j = 1:length(gridY)
                    % Translate the vertices to each grid position
                    translatedVertices = vertices + [gridX(i), gridY(j), 0];
                    
                    % Plot the steel tile at the current grid position
                    trisurf(faces, translatedVertices(:, 1), translatedVertices(:, 2), translatedVertices(:, 3), ...
                        'FaceColor', [0.7, 0.7, 0.7], 'EdgeColor', 'none', 'Parent', hAxes);
                end
            end
            
            % Optionally, adjust the appearance (e.g., lighting)
            camlight('headlight');
            lighting gouraud;
            material dull;
        end
    end
end
