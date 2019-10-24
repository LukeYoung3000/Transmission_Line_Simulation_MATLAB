function [Table] = impedance_function(...
    Cable_type, Line_length, GMD, GMR, r, R_km, ...
    d, n, ...
    freq)

%IMPEDANCE_FUNCTION:
% Calculates the impedance of an overhead transmission line based on its
% geometry and line parameters.
%
%   INPUTS
% Cable_type    (linked): Cell array of each cables product name
% Line_length   (linked): Total Line lengnth [Km] (Including Sag)
% GMR           (linked): GMR of the indivudual stranded conductor [mm]
% GMD           (linked): Geometric Mean Distance between phase bundles [m]
% r             (linked): Raduis of stranded conductor [m]
% R_km          (linked): Resistance per km of conductor
% d                 : Distance between conductors inside one bundle [m]
% n                 : Number of conductors per bundle (1 - 6)
%
%   OUTPUTS
% Table : Table of the following inputs and corrisponding outputs
% - Cable_type (In)
% - n          (In)
% - d          (In)
% - Xl         (Out) : Inductive Reactance [Ohm]
% - R          (Out) : Resistance [Ohm]
% - Xc         (Out) : Capacitive Reactance [Ohm]
%   
%
%   WARNNINGS
% All arguments MUST be COLUMN vectors!
%


display('--------------IMPEDANCE_FUNCTION----------------');

%-----------------------Inductance Calculations-----------------------

% Calculate the GMR_phase

% link_index is used to link varribles of the same cable types
link_index = [1:length(Cable_type)]';
[n_comb, link_index_comb, d_comb] = ndgrid(n, link_index, d);

%comb means combinations
n_comb = n_comb(:);
link_index_comb = link_index_comb(:);
d_comb = d_comb(:);
GMR_comb = GMR(link_index_comb)/1000; %Convert to meters

for i = 1:length(n_comb)
switch n_comb(i)
    case 1
       GMR_phase(i) = GMR_comb(i);
    case 2
        GMR_phase(i) = (d_comb(i).*GMR_comb(i)).^(1/2);
    case 3
        GMR_phase(i) = (d_comb(i).^2.*GMR_comb(i)).^(1/3);
    case 4
        GMR_phase(i) = 1.09*(d_comb(i).^3.*GMR_comb(i)).^(1/4);
    case 5
        GMR_phase(i) = 1.212*(d_comb(i).^4.*GMR_comb(i)).^(1/5);
    case 6
        GMR_phase(i) = 1.348*(d_comb(i).^5.*GMR_comb(i)).^(1/6);
    otherwise
        GMR_phase(i) = nan;
        display('n (Number of coductors per bundle) is out of range');
end
end
GMR_phase = GMR_phase'; %GMR phase is in meters

% Calculate Total Line Inductance
% Note: Cable_type, Line_length, GMD, GMR, are "Linked" varribles
L = Line_length(link_index_comb)*1000*2*10^(-7);
L = L.*log(GMD(link_index_comb)./(GMR_phase));

freq = 50; % Incorperate varrible frequncys when you can
Xl = 2*pi*freq.*L;

%-----------------------Capacitance Calculations-----------------------
r_comb = r(link_index_comb);

for i = 1:length(n_comb)
switch n_comb(i)
    case 1
        re(i) = r_comb(i);
    case 2
        re(i) = (d_comb(i)*r_comb(i))^(1/2);
    case 3
        re(i) = (d_comb(i)^2*r_comb(i))^(1/3);
    case 4
        re(i) = 1.09*(d_comb(i)^3*r_comb(i))^(1/4);
    case 5
        re(i) = 1.212*(d_comb(i)^4*r_comb(i))^(1/5);
    case 6
        re(i) = 1.348*(d_comb(i)^5*r_comb(i))^(1/6);
    otherwise
        display('n (Number of coductors per bundle) is out of range');
end
end
re = re';

ep_zero = 8.8541*10^-12;
C = Line_length(link_index_comb)*1000*2*pi*ep_zero;
C = C./(log(GMD(link_index_comb)./re));
Xc = 1./(2*pi*freq.*C);

%-----------------------Resistance Calulations-----------------------
R = R_km(link_index_comb).*Line_length(link_index_comb)./n_comb;

%-----------------------Construct Table-----------------------
Cable_type_comb = Cable_type(link_index_comb);
Table = table(Cable_type_comb,n_comb,d_comb,Xl,R,Xc);

display('------------------------------------------------');

end

