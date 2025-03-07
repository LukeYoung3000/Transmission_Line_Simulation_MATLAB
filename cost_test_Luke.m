clc
clear all
close all
warning("off");

% Create a list of all avalible text files
list = dir('cable_files/*.txt');    %Filter out .txt files for import
list = {list.name};

% Load parrameters from .txt files into data structs
for i = 1:length(list)
    cable_txt(i) = importdata(['cable_files/' num2str(list{i})],':'); %import info from .txt
    j = cable_txt(i).rowheaders(:,1);
    cable_struct(i).conductor = erase(list(i),'_AAAC1120.txt')';
    cable_struct(i).mass = cable_txt(i).data(find(contains(j,"Mass"),1),1);
    cable_struct(i).diameter = cable_txt(i).data(find(contains(j,"Overall Diameter"),1),1);
    cable_struct(i).expansion = cable_txt(i).data(find(contains(j,"Expansion"),1),1);
    cable_struct(i).GMR = cable_txt(i).data(find(contains(j,"GMR"),1),1);
    cable_struct(i).mbl = cable_txt(i).data(find(contains(j,"MBL"),1),1);
    cable_struct(i).resistance = cable_txt(i).data(find(contains(j,"Resistance"),1),1);
    cable_struct(i).csa = cable_txt(i).data(find(contains(j,"CSA"),1),1);
end
clear cable_txt

% Setup inputs to "impedance_function"
Cable_type = [cable_struct.conductor]';
GMR = [cable_struct.GMR]';
r = 0.5*[cable_struct.diameter]';
R_km = [cable_struct.resistance]';
% Approximate values for Line_length and GMD 
Line_length = 150*ones(length(Cable_type),1); 
GMD = 6*ones(length(Cable_type),1);

d = [0.4]'; % d = [0.2 0.3 0.4 0.5]';
n = [1:6]'; % n = [1:6]';

freq = 50;

Data_Power = impedance_function(Cable_type, Line_length, GMD, GMR, r, R_km, ...
    d, n, freq);

% Power Simulation
for i = 1: height(Data_Power)
    [Data_Power.Efficiency(i), Data_Power.V_reg(i)] = ...
        power_simulation(Data_Power.R(i),Data_Power.Xl(i),Data_Power.Xc(i));
end

% Cable Cost Table
AAAC_est = 4.409;       % Estimated price [AUD/Kg]
Length = 150;           % Km
Mass = [cable_struct.mass]'; Mass = Mass*1000/9.8; % [Kg/Km]
link_index = [1:length(Cable_type)]';
% Combinations
[n_comb, link_index_comb] = ndgrid(n, link_index);
n_comb = n_comb(:); link_index_comb = link_index_comb(:);
Cable_cost = 3*Length*AAAC_est.*n_comb.*Mass(link_index_comb);

Cable_type_comb = Cable_type(link_index_comb);
Data_Cable_Cost = table(Cable_type_comb,n_comb,Cable_cost);

% Power Losses and Loss Cost
P_max = 150; %[MW]
P_loss_max = P_max*(1-Data_Power.Efficiency)./Data_Power.Efficiency; %[MW]
P_loss_ave = 0.4*P_loss_max;
life_span = 50; %[years]
energy_price = 140; %[AUD/MWHr]
loss_cost = life_span*365*24*P_loss_ave*energy_price;
% Add to table
Data_Power.Loss_cost = loss_cost;

% Join tables
T = join(Data_Power,Data_Cable_Cost);
T.Total_cost = T.Loss_cost + T.Cable_cost;









