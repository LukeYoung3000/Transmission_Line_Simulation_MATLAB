clc
clear all
close all
warning("off");

%Generate cable properties struct
list = dir('cable_files/*.txt');    %Filter out .txt files for import
list = {list.name};

%inputs
height = 18; %arbitrary
span = 150; %arbitrary
totalDistance = 150000; %specified in project brief
cableFileName = list{13};
safetyFactor = 5; %within standards
ground_clearance_min = 7.5; %from standard AS/NZS 7000
windPressure = 1215;  %N/m^2
bundle_size = 6; %Now selected in cost analysis

%insulator inputs (from online estimation)
I_length = 2.590; %m
I_width = 0.05; %m (assumed)
I_mass = 14.4; %kg
I_load = 160000; %N
theta_con = 5; %degrees (NOT YET SURE HOW TO CHOOSE THIS VALUE...)

%Function call
[phi, weight_total, area, sag, ground_clearance, length_cable, total_cable_length,...
    blowout, ground_check, blowout_total, insulator_factor] = sag_function(height, span, totalDistance,...
    cableFileName, safetyFactor, ground_clearance_min,...
    windPressure,bundle_size, I_length, I_width, I_mass, theta_con, I_load);

%Tower requirements (minimum)
%TOWER HEIGHT
safety_add = 3; %clearance buffer
ext_min_tower = height - (ground_clearance-ground_clearance_min); %shortest tower within standards, no tolerance!
safety_height = ceil(ext_min_tower) + safety_add; %round up, add buffer

phase_distance_min = ceil(blowout_total) + 2;  %min distance b/w phases
disp(['Minimum phase distance         ' num2str(phase_distance_min) '[m]'])
display('------------------------------------------------');

%TOWER WIDTH (Tri Formation)
tri_height_above = sqrt((phase_distance_min^2)-((phase_distance_min/2)^2));
tri_tower_height = safety_height + tri_height_above;
tri_cross_arm = phase_distance_min/2;

%TOWER WIDTH (Flat Formation)
flat_cross_arm = phase_distance_min;
flat_tower_height = safety_height;

disp(['---------------' 'Tri Tower Config' '-----------------']);
disp(['Height                         ' num2str(tri_tower_height) '[m]'])
disp(['Cross arm span                 ' num2str(tri_cross_arm) '[m]'])
disp(['Upper conductor height delta   ' num2str(tri_height_above) '[m]'])

display('------------------------------------------------');

disp(['---------------' 'Flat Tower Config' '----------------']);
disp(['Height                         ' num2str(flat_tower_height) '[m]'])
disp(['Cross arm span                 ' num2str(flat_cross_arm) '[m]'])

display('------------------------------------------------');


