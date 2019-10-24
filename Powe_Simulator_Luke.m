% Use this script to test different impedance values in our medium legnth
% (pi model) overhead transmistion line.

% Line Parameters:
%R = 25.6181; Xl = 10.7618; Xc = inf;
R = 1; Xl = 30; Xc = inf; %from actual cables (XENON - AAAC 1120)

% Given Parameters (Dont Change):
Vs_line_to_line = 220*10^3; %3 Phase Supply Voltage (Sending Voltage)
P_load_3_phase = 150*10^6;  %Load Power
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

% Define power vectors:
Pbus = [P1 P2];
Qbus = [Q1 Q2];

% run function to solve the power flow
[Ebus, Ibus, Imat, iter] = ...
    power_flow_solver(Ymat, Pbus, Qbus, E1);

% display results
clc;
disp('---  SUMMARY OF RESULTS  ---');
disp('number of iterations until convergence:');
disp(iter);
disp('voltage magnitudes');
disp(abs(Ebus.'));
disp('voltage phase angles (degree)');
disp(angle(Ebus.')*180/pi);
disp('current supplied by each source (amplitude)');
disp(abs(Ibus.'));
disp('Active power supplied by each source');
disp(real(Ebus.*conj(Ibus)));
disp('Reactive power supplied by each source');
disp(imag(Ebus.*conj(Ibus)));
disp('current in bus 1 --> bus 2');
disp(Imat(1,2));
disp('shunt currents in each bus (magnitude)');
disp(abs(diag(Imat).'));


Efficiency_check = P_load/(real(Ebus(1)*conj(Ibus(1))))
if(Efficiency_check > Efficiency)
    disp('Efficiency Pass')
else
    disp('Efficiency Fail')
end

V_reg_check = (Vs - abs(Ebus(2)))/abs(Ebus(2))
if(V_reg_check < V_reg)
    disp('Voltage Regulation Pass')
else
    disp('Voltage Regulation Fail')
end




