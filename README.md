# Underwater Welding Robot System

## Project Overview

This project focuses on developing an innovative underwater welding robot system designed for marine applications such as repairing ships, offshore platforms, and underwater pipelines. The system features two synchronized robotic arms:

- **Feeder Robot (Omron TM5):** Supplies welding filler material to the welding site.
- **Welding Robot (Underwater Welder):** Performs the actual welding operation with high precision.

This dual-robot configuration enhances precision, efficiency, and safety in hazardous underwater environments by reducing the need for human divers and improving the quality of underwater welding tasks.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Installation and Setup](#installation-and-setup)
- [Usage](#usage)
  - [Running the Simulation](#running-the-simulation)
  - [Customizing the Simulation](#customizing-the-simulation)
- [File Descriptions](#file-descriptions)
- [Class Descriptions](#class-descriptions)
  - [OmronTM5 Class](#omrontm5-class)
  - [UnderwaterWelder Class](#underwaterwelder-class)
  - [Movement Class](#movement-class)
- [Collision Detection](#collision-detection)
- [Notes and Recommendations](#notes-and-recommendations)
- [License](#license)
- [Acknowledgments](#acknowledgments)

---

## Project Structure

```
UnderwaterWeldingRobotSystem/
├── OmronTM5.m
├── UnderwaterWelder.m
├── Movement.m
├── main.m
├── README.md
```

---

## Prerequisites

- **MATLAB** (R2017 or later recommended)
- **Robotics Toolbox for MATLAB** by Peter Corke
  - Download: [Robotics Toolbox](https://petercorke.com/toolboxes/robotics-toolbox/)
- **Optional:** MATLAB's **Robotics System Toolbox** for advanced features like collision detection

---

## Installation and Setup

1. **Install MATLAB**

   Ensure that MATLAB is installed on your system.

2. **Install the Robotics Toolbox**

   - Download the toolbox from [Peter Corke's website](https://petercorke.com/toolboxes/robotics-toolbox/).
   - Add the toolbox to your MATLAB path:
     ```matlab
     addpath('path_to_robotics_toolbox');
     savepath;
     ```

3. **Clone or Download the Project Repository**

   - Clone the repository using Git:
     ```bash
     git clone https://github.com/yourusername/UnderwaterWeldingRobotSystem.git
     ```
   - Or download the ZIP file and extract it to a directory.

4. **Add the Project Folder to MATLAB Path**

   In MATLAB, add the project folder and subfolders to the path:

   ```matlab
   addpath(genpath('path_to_project_folder'));
   savepath;
   ```

---

## Usage

### Running the Simulation

1. **Open MATLAB**

   Launch MATLAB on your system.

2. **Navigate to the Project Directory**

   In the MATLAB Command Window:

   ```matlab
   cd 'path_to_project_folder';
   ```

3. **Run the Main Script**

   Execute the `main.m` script:

   ```matlab
   main;
   ```

   This script initializes the robots, defines a welding path, and synchronizes the robots along the path. Visualizations of the robots and their movements will appear in figure windows.

### Customizing the Simulation

- **Adjust the Welding Path**

  Modify the `weldingPoints` array in `main.m` to change the welding trajectory:

  ```matlab
  weldingPoints = [
      x1, y1, z1;
      x2, y2, z2;
      x3, y3, z3;
      % Add more points as needed
  ];
  ```

- **Modify Robot Parameters**

  Update the Denavit-Hartenberg (DH) parameters in `OmronTM5.m` and `UnderwaterWelder.m` with accurate values for realistic simulations.

- **Implement Collision Detection**

  Enhance the `checkCollision` method in `Movement.m` to perform actual collision detection using appropriate toolboxes or custom algorithms.

---

## File Descriptions

- **OmronTM5.m**

  Defines the `OmronTM5` class representing the feeder robot arm.

- **UnderwaterWelder.m**

  Defines the `UnderwaterWelder` class representing the welding robot arm.

- **Movement.m**

  Defines the `Movement` class that synchronizes the movements of the feeder and welding robots.

- **main.m**

  The main script that initializes the robots, defines the welding path, and runs the simulation.

- **README.md**

  Documentation file providing an overview and instructions for the project.

---

## Class Descriptions

### OmronTM5 Class

**File:** `OmronTM5.m`

**Description:**

Represents the feeder robot arm based on the Omron TM5 model. It supplies welding filler material to the welding site.

**Key Methods:**

- `plotRobot(q)`: Plots the robot at a given joint configuration `q`.
- `moveToPoint(point)`: Moves the robot's end-effector to a specified 3D `point`.

---

### UnderwaterWelder Class

**File:** `UnderwaterWelder.m`

**Description:**

Represents the welding robot arm that performs the actual underwater welding operation with high precision.

**Key Methods:**

- `plotRobot(q)`: Plots the robot at a given joint configuration `q`.
- `moveToPoint(point)`: Moves the robot's end-effector to a specified 3D `point`.

---

### Movement Class

**File:** `Movement.m`

**Description:**

Manages the synchronization of the feeder and welding robots along a predefined welding path.

**Key Methods:**

- `synchronizeRobots(weldingPoints)`: Coordinates the robots to move along the `weldingPoints`.
- `checkCollision(qFeeder, qWelder)`: Checks for potential collisions between the robots at configurations `qFeeder` and `qWelder`.

---

## Collision Detection

**Note:** The `checkCollision` method in `Movement.m` currently contains placeholder logic and assumes no collisions occur. To implement actual collision detection:

1. **Use Robotics System Toolbox Functions**

   - Convert `SerialLink` models to `RigidBodyTree` models if necessary.
   - Use `checkCollision` function:
     ```matlab
     [isCollision, sepDist] = checkCollision(feederRobotModel, qFeeder', weldingRobotModel, qWelder');
     ```

2. **Define Collision Bodies**

   - Specify collision geometry for each link of the robots.
   - Use `collisionCylinder`, `collisionBox`, etc., to define shapes.

3. **Update `checkCollision` Method**

   Replace the placeholder code with the actual collision detection logic.

---

## Notes and Recommendations

- **Replace Placeholder DH Parameters**

  Ensure that the DH parameters in `OmronTM5.m` and `UnderwaterWelder.m` are updated with the actual robot specifications for accurate simulations.

- **Robotics Toolbox vs. Robotics System Toolbox**

  - The **Robotics Toolbox** by Peter Corke is free and suitable for educational purposes.
  - The **Robotics System Toolbox** is a MathWorks product that provides advanced features but requires a license.

- **Visualization**

  - The `plot` and `plot3d` functions are used for visualization.
  - Adjust the `workspace` parameter in plotting functions to fit the size of your robots.

- **Underwater Environment Simulation**

  - To simulate underwater conditions, consider adding environmental models and adjusting robot dynamics to account for factors like buoyancy and water resistance.

- **Error Handling**

  - Implement error checks and exception handling to make the simulation robust.

- **Future Enhancements**

  - Implement a GUI for interactive control.
  - Add logging capabilities to record robot movements.
  - Integrate sensor models for feedback control.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Acknowledgments

- **Peter Corke**

  - For developing the Robotics Toolbox for MATLAB, which is instrumental in robot modeling and simulation.

- **MATLAB Community**

  - For providing resources and support in robotics and automation projects.

---

**Contact Information**

For questions or suggestions regarding this project, please contact:

- **Name:** Your Name
- **Email:** your.email@example.com
- **GitHub:** [yourusername](https://github.com/yourusername)

---
