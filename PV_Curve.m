% Use this script to test different impedance values in our medium legnth
% (pi model) overhead transmistion line.
clc;
clear all;

% Line Parameters:

% Good Chartieristics
R = 1.5; Xl = 30.00; Xc = 1200.00;

% Bad Chartieristics
% R = 13; Xl = 60.00; Xc = 2000.00;

% Given Parameters (Dont Change):
Vs_line_to_line = 220*10^3; %3 Phase Supply Voltage (Sending Voltage)
P_load_3_phase = 150*10^6;  %Load Power (Nominal 150Wm)
V_reg = 0.15;               %Voltage Regulation
Efficiency = 0.70;          %P_in/P_out
PF_min = 0.70;              %Power Factor
PF_angle = acos(PF_min);    %Power Factor Angle

% Per Phase Model (Dont Change):
P_load = P_load_3_phase/3;              % Active load (per phase)
Q_load = (P_load/PF_min)*sin(PF_angle); % Max reactive load (per phase)
Vs = Vs_line_to_line/sqrt(3);           % Supply voltage (per phase)
Vr = Vs/(1+V_reg);                      % Minimum load voltage magnitude (Reciving Voltage)
P_in = P_load/Efficiency;               % Maximum power input
P_loss = P_in - P_load;                 % Maximum resistive line losses


P_load = (0:10:1000)*10^6/3;             % Load Power Range

%%%%%%% Define the network  %%%%%%%
% The network composes three buses.
% bus 1 - (slack bus) a voltage source
% bus 2 - a load.

% Define the line impedances:
z12 = R + j*Xl;  % impedance (inductive) connecting bus 1 to 2.
z11 = -j*Xc;  % shunt impedance at bus 1
z22 = -j*Xc;  % shunt impedance at bus 2

% A matrix of the network impedances
Zmat = [z11 z12 ;
        z12 z22];

% compute the admittance matrix (admittamce = 1/impedance):
Ymat = 1./Zmat;

% Define voltage at bus 1
E1_phase = 0; % degree (reference phase angle).
E1_mag = Vs; % voltage magnitude
E1 = E1_mag*exp(j*E1_phase*(pi/180));

% Define generators and loads.
% Pg&Qg - generators.   Pl&Ql - loads.
Pg1=0;  Qg1=0; Pl1=0; Ql1=0; % no power source on the slack bus.
Pg2=0;  Qg2=0; Pl2=P_load; Ql2=Q_load;  % bus 2. generator and load.

% sum generators and load to form united power sources.
% (generators taken positive, loads taken negative).
P1 = Pg1 - Pl1;
P2 = Pg2 - Pl2;
Q1 = Qg1 - Ql1;
Q2 = Qg2 - Ql2;

% run function to solve the power flow
simulation_convegence = 1; i = 0;
while simulation_convegence == 1
    i = i + 1;
    Pbus = [P1 P2(i)];
    Qbus = [Q1 Q2];
    
    [Ebus, Ibus, Imat, iter] = ...
        power_flow_solver(Ymat, Pbus, Qbus, E1);
    
    if sum(isnan(Ebus))
        simulation_convegence = 0;
        i = i - 1;
    else
        E_2(i,1) = Ebus(2);
    end
    
    if i >= length(P_load)
        simulation_convegence = 0;
    end
    
end

VR = (Vs - abs(E_2))./abs(E_2);
P_load = 3*P_load(1:i);
% plot(P_load,abs(E_2)./Vs)
plot(P_load,VR)




