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
        fishModel1   % Property to store the fish1 model
        fishModel2   % Property to store the fish2 model
        coralModel1  % Property to store the coral1 model
        coralModel2  % Property to store the coral2 model
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

            % Initialize models as empty
            self.welderModel = [];  % Initialize welderModel
            self.columnModel = [];  % Initialize columnModel
            self.steelTileModel = [];  % Initialize steelTileModel
            self.fishModel1 = [];  % Initialize fish1 model
            self.fishModel2 = [];  % Initialize fish2 model
            self.coralModel1 = [];  % Initialize coral1 model
            self.coralModel2 = [];  % Initialize coral2 model

            % Create a new figure and plot environment when instantiated
            figure;
            hAxes = gca;  % Get current axes
            self.plotEnvironment(hAxes);  % Plot the environment
            
            % Adjust the camera view to see all walls
            view(3);      % Set 3D view
            axis equal;   % Maintain aspect ratio
            
            % Load and plot other elements
            self.loadAndPlotColumn(hAxes);      % Column
            self.loadAndPlotFish(hAxes);        % Fish
            self.loadAndPlotCoral(hAxes);       % Coral
        end
        
        % Method to plot the environment (floor and walls)
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
            
            % Translate the column to press against Wall 4
            translationVector = [0, 0.5, 0]; 
            vertices = vertices + translationVector;  % Apply translation
            
            % Plot the column model using trisurf
            trisurf(faces, vertices(:, 1), vertices(:, 2), vertices(:, 3), ...
                'FaceColor', [0.8, 0.8, 0.8], 'EdgeColor', 'none', 'Parent', hAxes);
            
            % Optionally, adjust the appearance (e.g., lighting)
                camlight('headlight');
                lighting gouraud;
                material dull;
        end
        
        % Method to load and plot the fish models
        function loadAndPlotFish(~, hAxes)
            % Load fish1 and fish2 PLY files
            [faces1, vertices1, ~] = plyread('Data/fish1.ply', 'tri');
            [faces2, vertices2, ~] = plyread('Data/fish2.ply', 'tri');
            
            % Apply a scaling factor to both fish models (adjust the scaling factor as needed)
            vertices1 = vertices1 * 0.01;  % Scaling for fish1
            vertices2 = vertices2 * 0.06;  % Scaling for fish2
            
            % Rotate both fish by 180 degrees around the X-axis to correct their orientation
            rotationMatrix = [1, 0, 0;
                              0, cosd(180), -sind(180);
                              0, sind(180), cosd(180)];
            
            vertices1 = (rotationMatrix * vertices1')';  % Apply rotation to fish1
            vertices2 = (rotationMatrix * vertices2')';  % Apply rotation to fish2
            
            % Define positions for the fish models (floating in the air)
            fishPos1 = [1.5, 0.5, 1.0];  % X, Y, Z position for fish1
            fishPos2 = [-1.0, -0.5, 1.5]; % X, Y, Z position for fish2
            
            % Translate fish models to their respective positions
            vertices1 = vertices1 + fishPos1;
            vertices2 = vertices2 + fishPos2;
            
            % Plot fish1 and fish2
            trisurf(faces1, vertices1(:, 1), vertices1(:, 2), vertices1(:, 3), ...
                'FaceColor', [0.5, 0.5, 1], 'EdgeColor', 'none', 'Parent', hAxes);
            trisurf(faces2, vertices2(:, 1), vertices2(:, 2), vertices2(:, 3), ...
                'FaceColor', [1, 0.5, 0.5], 'EdgeColor', 'none', 'Parent', hAxes);
            
            % Adjust appearance
            camlight('headlight');
            lighting gouraud;
            material dull;
        end

        % Method to load and plot the coral models
        function loadAndPlotCoral(~, hAxes)
            % Load the first coral PLY file
            [faces1, vertices1, ~] = plyread('Data/coral1.ply', 'tri');
            
            % Scale the coral1 model (adjust the scaling factor as needed)
            vertices1 = vertices1 * 0.01;  % Apply scaling factor to reduce size
            
            % Rotate the coral 180 degrees around the X-axis to flip it
            rotationMatrix1 = [1, 0, 0;
                               0, cosd(180), -sind(180);
                               0, sind(180), cosd(180)];
            
            vertices1 = (rotationMatrix1 * vertices1')';  % Apply rotation to vertices
            
            % Translate and plot the first coral
            translationVector1 = [1.5, -1.8, 0];  % Adjust for position
            vertices1 = vertices1 + translationVector1;  % Apply translation
            
            trisurf(faces1, vertices1(:, 1), vertices1(:, 2), vertices1(:, 3), ...
                'FaceColor', [0.4, 0.8, 0.4], 'EdgeColor', 'none', 'Parent', hAxes);
            
            % Load the second coral PLY file
            [faces2, vertices2, ~] = plyread('Data/coral2.ply', 'tri');
            
            % Scale the coral2 model (adjust the scaling factor as needed)
            vertices2 = vertices2 * 0.01;  % Apply scaling factor to reduce size
            
            % Rotate the second coral 180 degrees around the X-axis
            rotationMatrix2 = [1, 0, 0;
                               0, cosd(180), -sind(180);
                               0, sind(180), cosd(180)];
            
            vertices2 = (rotationMatrix2 * vertices2')';  % Apply rotation
            
            % Translate and plot the second coral
            translationVector2 = [-1.5, 1.0, 0];  % Adjust for position
            vertices2 = vertices2 + translationVector2;  % Apply translation
            
            trisurf(faces2, vertices2(:, 1), vertices2(:, 2), vertices2(:, 3), ...
                'FaceColor', [0.8, 0.5, 0.3], 'EdgeColor', 'none', 'Parent', hAxes);
            
            % Adjust appearance
            camlight('headlight');
            lighting gouraud;
            material dull;
        end
    end
end
