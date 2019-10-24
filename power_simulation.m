function [Efficiency, V_reg] = power_simulation(R,Xl,Xc)
% Use this script to test different impedance values in our medium legnth
% (pi model) overhead transmistion line.

% Given Parameters (Dont Change):
Vs_line_to_line = 220*10^3; %3 Phase Supply Voltage (Sending Voltage)
P_load_3_phase = 150*10^6;  %Load Power
V_reg_req = 0.15;               %Voltage Regulation
Efficiency_req = 0.70;          %P_in/P_out
PF_min = 0.70;              %Power Factor
PF_angle = acos(PF_min);    %Power Factor Angle

% Per Phase Model (Dont Change):
P_load = P_load_3_phase/3;              % Active load (per phase)
Q_load = (P_load/PF_min)*sin(PF_angle); % Max reactive load (per phase)
Vs = Vs_line_to_line/sqrt(3);           % Supply voltage (per phase)
Vr = Vs/(1+V_reg_req);                      % Minimum load voltage magnitude (Reciving Voltage)
P_in = P_load/Efficiency_req;               % Maximum power input
P_loss = P_in - P_load;                 % Maximum resistive line losses


%%%%%%% Define the network  %%%%%%%
% The network composes three buses.
% bus 1 - (slack bus) a voltage source
% bus 2 - a load.

% Define the line impedances:
z12 = R + j*Xl;  % impedance (inductive) connecting bus 1 to 2.
z11 = -j*2*Xc;  % shunt impedance at bus 1
z22 = -j*2*Xc;  % shunt impedance at bus 2

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

disp('----------  Power Simulation Results  ----------');

% Check if simulation did NOT convege
if(iter >= 100000)
   disp('Simulation Did NOT Converge');
   Efficiency = nan;
   V_reg = nan;
      
else
    % Calulate Results
    E_1_Mag = abs(Ebus(1));
    E_2_Mag = abs(Ebus(2));
    E_1_phase = angle(Ebus(1))*180/pi;
    E_2_phase = angle(Ebus(2))*180/pi;
    I_1_Mag = abs(Ibus(1));
    I_2_Mag = abs(Ibus(2));
    I_1_phase = angle(Ibus(1))*180/pi;
    I_2_phase = angle(Ibus(2))*180/pi;
    P_s = real(Ebus(1)*conj(Ibus(1)));
    P_l = real(Ebus(2)*conj(Ibus(2)));
    Q_s = imag(Ebus(1)*conj(Ibus(1)));
    Q_l = imag(Ebus(2)*conj(Ibus(2)));
    I_shunt_1 = abs(Imat(1,1));
    I_shunt_2 = abs(Imat(2,2));
    I_line = Imat(1,2); % current in bus 1 --> bus 2
    Efficiency = P_load/(real(Ebus(1)*conj(Ibus(1))));
    V_reg = (Vs - abs(Ebus(2)))/abs(Ebus(2));
    
    %Display Results
    disp(['Convergence Iterations  : ' num2str(iter)])
    
    disp(['Bus 1 (Slack Bus)       :']);
    disp(['Voltage Magnitude       : ' num2str(E_1_Mag) '[V]'])
    disp(['Voltage Angle           : ' num2str(E_1_phase) '[Deg]'])
    disp(['Current Magnitude       : ' num2str(I_1_Mag) '[A]'])
    disp(['Current Angle           : ' num2str(I_1_phase) '[Deg]'])
    disp(['Real Power              : ' num2str(P_s) '[W]'])
    disp(['Reactive Power          : ' num2str(Q_s) '[VAR]'])
    disp(['Shunt Current           : ' num2str(I_shunt_1) '[A]'])
    
    disp(['Bus 2 (Load Bus):']);
    disp(['Voltage Magnitude       : ' num2str(E_2_Mag) '[V]'])
    disp(['Voltage Angle           : ' num2str(E_2_phase) '[Deg]'])
    disp(['Current Magnitude       : ' num2str(I_2_Mag) '[A]'])
    disp(['Current Angle           : ' num2str(I_2_phase) '[Deg]'])
    disp(['Real Power              : ' num2str(P_l) '[W]'])
    disp(['Reactive Power          : ' num2str(Q_l) '[VAR]'])
    disp(['Shunt Current           : ' num2str(I_shunt_2) '[A]'])
    
    disp([' ']);
    disp(['Line Current            : ' num2str(I_line) '[A]'])
    if(Efficiency > Efficiency_req)
        check = 'pass';
    else
        check = 'fail';
    end
    disp(['Efficiency              : ' num2str(Efficiency) ' (' check ')'])
    if(V_reg < V_reg_req)
        check = 'pass';
    else
        check = 'fail';
    end
    disp(['Voltage Regulation      : ' num2str(V_reg) ' (' check ')'])
    
    disp(['Note: ']);
    disp(['Results Have Been Converted To Per Phase Values'])
end

display('------------------------------------------------');

end

