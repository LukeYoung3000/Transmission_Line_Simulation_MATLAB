function [sag, ground_clearance, length_cable,...
    total_cable_length, blowout, ground_check] = sag_functiontest(height, span,...
    totalDistance, list, safetyFactor, ground_clearance_min, thicknessIce,...
    windPressure)

disp(['----------------' 'Sag Simulation' '------------------']);

if nargin < 7
        thickness_ice = 0;
        wind_pressure = 0;
elseif nargin == 7
        thickness_ice = thicknessIce; %m 
        wind_pressure = 0;
elseif nargin == 8
        thickness_ice = thicknessIce; %m
        wind_pressure = windPressure; %Pa
end

%Cable properties
for i = 1:length(list)
    cable_info{i} = importdata((list{i}),':'); %import info from .txt
    j = cable_info{1,1}.rowheaders(:,1);
    p = [find(contains(j,'Mass'),1), find(contains(j,'MBL'),1)...
      find(contains(j,'Overall Diameter'),1),...
      find(contains(j,'Expansion'),1)];
  
    cable_weight(i) = cable_info{1,i}.data(p(1),1);
    conductor_diameter(i) = cable_info{1,i}.data(p(1),1);
    MBL_cable(i) = cable_info{1,i}.data(p(1),1);
    alpha_cable(i) = cable_info{1,i}.data(p(1),1);
end

[height span safetyFactor totalDistance cable_weight...
    conductor_diameter MBL_cable alpha_cable] = ndgrid(height, span,...
    safetyFactor, totalDistance, cable_weight,...
    conductor_diameter, MBL_cable, alpha_cable);

working_tension = MBL_cable/2
everyday_tension = MBL_cable/safetyFactor(:)

% %Ice Properties
% volume=((pi*thickness_ice)*(conductor_diameter+thickness_ice)); %m^3
% area = conductor_diameter+(2*thickness_ice); %m^2
% density = 917; %Kg/m^3
% 
% %per-unit length weights
% weight_ice = density*volume; %N
% weight_wind = wind_pressure*area; %N
% weight_total = sqrt(((weight_cable + weight_ice)^2)+((weight_wind)^2));
% 
% %Sag calculation (Caternary)
% constant = everyday_tension/weight_total;
% sag = constant*(cosh(span/(2*constant))-1); %Catenary Formula
% ground_clearance = height - sag;
% 
% %length of hanging (caternary) cable based on sag and span
% length_cable = 2*(constant*sinh((span/2)/constant));
% 
% %required number of towers and total length of cable required 
% towers_needed = totalDistance/span;
% total_cable_length = ((length_cable/span)*totalDistance);
% 
% %cable length and sag after thermal expansion (assuming To = 25 C)
% delta_length = (alpha*(10^-6))*10*length_cable;
% new_length = delta_length+length_cable;
% slack = (new_length) - span;
% new_sag = sqrt((3*span*(slack))/8); 
% 
% %Blowout calculation
% theta = atand((900*conductor_diameter)/weight_cable);
% blowout = sag*sind(theta); %Horizontal blowout distance
% new_blowout = new_sag*sind(theta);
% 
% %Ground clearance check with reference to standards
% if ground_clearance > ground_clearance_min
%     ground_check = 1;
% else
%     ground_check = 0;
% end
% 
% disp(['Sag                            ' num2str(sag) '[m]'])
% disp(['New Sag                        ' num2str(new_sag) '[m]'])
% disp(['Everyday Tension               ' num2str(everyday_tension) '[N]'])
% disp(['Ground clearance of conductor  ' num2str(ground_clearance) '[m]'])
% disp(['Cable length across span       ' num2str(length_cable) '[m]'])
% disp(['Total length of cable          ' num2str(total_cable_length) '[km]'])
% disp(['No. of towers in network       ' num2str(towers_needed)])
% disp(['Horizontal blowout (900Pa)     ' num2str(blowout) '[m]'])
% disp(['New Blowout                    ' num2str(new_blowout) '[m]'])
% 
% display('------------------------------------------------');
end

