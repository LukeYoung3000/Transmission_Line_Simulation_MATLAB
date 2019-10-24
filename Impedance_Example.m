% Impedance Example
clc; clear all;

% Uncomment the cable you would like to test:

cableFileName = 'XENON_AAAC1120.txt'; n = 1;
%cableFileName = 'SULPHUR_AAAC1120.txt';
%cableFileName = 'SILICON_AAAC1120.txt';
%cableFileName = 'OXYGEN_AAAC1120.txt'; n = 2;
%cableFileName = 'KRYPTON_AAAC1120.txt'; n = 3; 


Line_length = 1;   % Total Line lengnth [Km] (Including Sag) 150.5
d = 0.4;               % Distance between conductors inside one bundle [m]
GMD = 0.3;              % Geometric Mean Distance between phase bundles [m]

[Xl,R,Xc] = impedance_function(Line_length, cableFileName, d, n, GMD);