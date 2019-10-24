clc
clear all
close all
warning("off");


list = dir('*.txt');
list = {list.name};

%sag function inputs
tower_height = 20;
span = 150;
total_length = 150000;
safety_factor = 5;
ground_clearance_min = 7.5;
ice_thickness = 0;
wind_pressure = 0;

%impedance function inputs
d = 0.4; % Distance between conductors inside one bundle [m]


for i = 1:length(list)
    disp(['-------------' list{i} '---------------']);
    
    [sag(i), ground_clearance(i), length_cable(i),...
        total_cable_length(i), blowout(i), ground_check(i)] = sag_function(tower_height,...
        span, total_length, list{i}, safety_factor,...
        ground_clearance_min, ice_thickness, wind_pressure);
    
    cable_name(i) = list(i);
    
    %impedance function inputs
    GMD(i) = ceil(blowout(i)*2) + 2; % Geometric Mean Distance between phase bundles [m]
    Line_length(i) = total_cable_length(i); % Total Line lengnth [Km] (Including Sag)
    n_min = 2; n_max = 6; n = [n_min:n_max]';
    
    for q = 1:length(n);
        p = q + (i-1)*length(n);
        [Xl(p),R(p),Xc(p)] = impedance_function(Line_length(i), list{i}, d, n(q), GMD(i));
        [Eff(p), VoltReg(p)] = power_simulation(R(p), Xl(p), Xc(p));
        cable_type_vec(p) = list(i);
        ground_clearance_vec(p) = ground_clearance(i);
        GMD_vec(p) = GMD(i);
        n_vec(p) = n(q);
    end
end

% Data In Table
inter_bundle_distance = d;
Data_In = table(tower_height,span,total_length,safety_factor,...
    ice_thickness,wind_pressure,inter_bundle_distance);

% Data Out Sag Table
sag = sag';
ground_clearance = ground_clearance';
length_cable = length_cable';
total_cable_length = total_cable_length';
blowout = blowout';
phase_distance = ceil(blowout*2)+2;
cable_name = cable_name';
cable_name = erase(cable_name,'.txt');
ground_check = ground_check';
Data_Out_Sag = table(cable_name,sag,ground_clearance, ground_check, length_cable,...
    total_cable_length, blowout, phase_distance)

% Data Out Table
ground_clearance_vec = ground_clearance_vec';
cable_type_vec = cable_type_vec';
cable_type_vec = erase(cable_type_vec, '.txt');
GMD_vec = GMD_vec';
n_vec = n_vec';
Xl = Xl'; R = R'; Xc = Xc'; Eff = Eff'; VoltReg = VoltReg';
Eff_pass = 0.7;
Eff_check = (Eff > Eff_pass);
VoltReg_pass = 0.15;
VoltReg_check = (VoltReg < VoltReg_pass);
Data_Out = table(cable_type_vec, ground_clearance_vec, GMD_vec, n_vec, ...
    Xl, R, Xc, Eff, VoltReg, Eff_check, VoltReg_check)
Data_Out = sortrows(Data_Out,'VoltReg','ascend');

% Save Data to XLXS file
filename = 'data.xlsx';
writetable(Data_In,filename,'Sheet',1,'Range','A1');
writetable(Data_Out_Sag,filename,'Sheet',2,'Range','A1');
writetable(Data_Out,filename,'Sheet',3,'Range','A1');



