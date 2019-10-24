clc
clear all
close all
warning("off");

%function parameters 

    %sag function
tower_height = 30;
span = 300;
total_length = 150000;
safety_factor = 5;
ice_thickness = 0;
wind_pressure = 0;

    %impedance function
Line_length = 150.5;   % Total Line lengnth [Km] (Including Sag)
d = 0.1;               % Distance between conductors inside one bundle [m]
GMD = 8;               % Geometric Mean Distance between phase bundles [m]
n = 3;

%function calls

[list,selection] = text_file_selector();

[sag, ground_clearance, length_cable, total_cable_length] = ...
    sag_function(tower_height, span, total_length, list{selection},...
    safety_factor, ice_thickness, wind_pressure);

[Xl,R,Xc] = impedance_function(Line_length, list{selection}, d, n, GMD);