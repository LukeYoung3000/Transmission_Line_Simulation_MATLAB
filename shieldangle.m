clc
clear all
close all

shield_angle = 20:40;

%Tri/staggered configuration with 1 shield wire
for i = 1:length(shield_angle)
    height(i) = 3.8971/tand(shield_angle(i));
end

figure
plot(shield_angle,height)

%FLAT CONFIGURATION WILL NEED NEW ELECTRICAL FORMULAS! DONT USE
%Flat configuration with 1 shield wire
for i = 1:length(shield_angle)
    height(i) = 9/tand(shield_angle(i));
end

figure
plot(shield_angle,height)


%Flat configuration with two shield wires
for i = 1:length(shield_angle)
    height(i) = 4.5/tand(shield_angle(i));
end

figure
plot(shield_angle,height)