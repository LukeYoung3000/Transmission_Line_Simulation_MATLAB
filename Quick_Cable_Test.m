clc; clear all; close all;
warning("off");

%function calls
[list,selection] = text_file_selector();

%sag function
tower_height = 30;
span = 150;
total_length = 150000;
safety_factor = 5;
ice_thickness = 0;
wind_pressure = 0;

[sag, ground_clearance, length_cable, total_cable_length, blowout] = ...
    sag_function(tower_height, span, total_length, list{selection},...
    safety_factor, ice_thickness, wind_pressure);

%impedance function
d = 0.4;               % Distance between conductors inside one bundle [m]
GMD = 5;               % Geometric Mean Distance between phase bundles [m]
n = 1;
Line_length = total_cable_length;   % Total Line lengnth [Km] (Including Sag)

[Xl,R,Xc] = impedance_function(Line_length, list{selection}, d, n, GMD);

power_simulation(R, Xl, Xc);