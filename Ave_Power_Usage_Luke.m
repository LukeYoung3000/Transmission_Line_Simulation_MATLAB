% Graph used in the report!

Ave_Power_Data = 150*(1/1.4)*[ ...
    0.41 0.36 0.34 0.325 0.32 0.37 0.5 0.6 0.57 0.52 0.5 0.51 0.52 0.52 0.54 ...
    0.6 0.71 0.88 1 0.95 0.9 0.82 0.65 0.5];

Mean_Ave_Power_Data = trapz(Ave_Power_Data)/24;

figure()
hold on
plot(Ave_Power_Data)
plot([1 24],Mean_Ave_Power_Data*[1 1])
ylim([0 150])