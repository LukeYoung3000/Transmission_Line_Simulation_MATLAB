clc
clear all
close all

phase_d = 8;
shield_angle = 20:40;
vert_sep = phase_d;
ins_length = 2.590;

horizontal_sep = sqrt(phase_d^2-(0.5*phase_d)^2);
cross_arm_sep = 0.5*phase_d;


%Tri/staggered configuration with 1 shield wire
for i = 1:length(shield_angle)
    height(i) = ((horizontal_sep/2)/tand(shield_angle(i)));
end

figure
grid on
plot(shield_angle,height)
title('Ground wire height (above upper conductor) vs Shield angle');
xlabel('Shield angle [degrees]');
ylabel('Ground wire height [m]');
