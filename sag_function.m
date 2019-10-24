function [phi_insulator, weight_total, area, sag, ground_clearance, length_cable, total_cable_length,...
    blowout, ground_check, blowout_total, insulator_factor] = sag_function(height, span, totalDistance,...
    cableFileName, safetyFactor, ground_clearance_min,...
    windPressure, bundle_size, I_length, I_width, I_mass, theta_con, I_load)

disp(['----------------' 'Sag Simulation' '------------------']);

%Cable properties
cable_info = importdata(strcat('cable_files/',num2str(cableFileName)),':'); %import info from .txt
j = cable_info.rowheaders(:,1);
p = [find(contains(j,"Mass"),1), find(contains(j,"MBL"),1),...
      find(contains(j,"Overall Diameter"),1),...
      find(contains(j,"Expansion"),1)];
weight_cable = cable_info.data(p(1),1);
MBL_cable = cable_info.data(p(2),1);
conductor_diameter = cable_info.data(p(3),1);

working_tension = MBL_cable/2;
everyday_tension = MBL_cable/safetyFactor;

area = conductor_diameter; %m^2

%per-unit length weights
weight_wind = windPressure*area %N
weight_total = sqrt(((weight_cable)^2)+((weight_wind)^2)); %N

%Sag calculation (Catenary)
constant = everyday_tension/weight_total;
sag = constant*(cosh(span/(2*constant))-1); %Catenary Formula
ground_clearance = height - I_length - sag;

%Ground clearance check with reference to standards
if ground_clearance > ground_clearance_min
    ground_check = 'Pass';
else
    ground_check = 'Fail';
end

%length of hanging (caternary) cable based on sag and span
length_cable = 2*(constant*sinh((span/2)/constant));


%shield_weight (assumed identical conductor to phases)
shield_weight = weight_cable*length_cable

%span weight (includes wind load weight)
span_weight = (length_cable*weight_cable*bundle_size)+(weight_wind*length_cable);

total_span_weight = 3*((I_mass*9.81)+span_weight)+shield_weight;

cross_arm_tension = span_weight+I_mass*9.81;

%insulator tension factor
insulator_factor = I_load/span_weight;

if insulator_factor < 5
    insulator_strength_test = 'Fail';
else
    insulator_strength_test = 'Pass';
end

%required number of towers and total length of cable required 
towers_needed = totalDistance/span;
total_cable_length = ((length_cable/span)*totalDistance);

%Blowout calculation (with no insulation swing)
theta = atand((windPressure*conductor_diameter)/weight_cable)
blowout = sag*sind(theta); %Horizontal blowout distance

%Insulator swing out
%Insulator height = 2.5m based on research averages
Cd = 1.2; %constant
Qz = windPressure; %dynamic pressure on member
A = I_length*I_width; %area of insulator normal to the wind force
Fw_insulator = Qz*Cd*A;  %Wind load on insulator string

phi_insulator = atand(((windPressure*bundle_size*conductor_diameter*I_length)...
    +(Fw_insulator/2)+(2*everyday_tension*bundle_size*sind(theta_con/2)))...
    /((span*bundle_size*weight_cable)+((14.4*9.81)/2)));

swing_insulator = I_length*sind(phi_insulator);

%Combined blowout
blowout_total = (sag*sind(theta))+swing_insulator+((0.5)*(0));

disp(['Sag                            ' num2str(sag) '[m]'])
disp(['Everyday Tension               ' num2str(everyday_tension) '[N]'])
disp(['Ground clearance of conductor  ' num2str(ground_clearance) '[m]'])
disp(['Ground check (pass/fail)       ' num2str(ground_check)])
disp(['Insulator strength (pass/fail) ' num2str(insulator_strength_test)])
disp(['Cable length across span       ' num2str(length_cable) '[m]'])
disp(['Span Weight                    ' num2str(span_weight) '[N]'])
disp(['Cross arm tension              ' num2str(cross_arm_tension) '[N]'])
disp(['Total Span Weight              ' num2str(total_span_weight) '[N]'])
disp(['Total length of cable          ' num2str(total_cable_length) '[km]'])
disp(['No. of towers in network       ' num2str(towers_needed)])
disp(['Horizontal blowout             ' num2str(blowout) '[m]'])
disp(['Insulator swing                ' num2str(swing_insulator) '[m]'])
disp(['Blowout total                  ' num2str(blowout_total) '[m]'])
end

