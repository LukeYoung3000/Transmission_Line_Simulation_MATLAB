function [total_price, cable_price, loss_price] = cost_function(... 
    mass_per_km,...     % Kg/Km
    n_conductors,...    % Number of Inter Bundle Conductors
    length,...          % Km (Constant)
    AAAC_per_ton,...    % Cost of AAAC per ton (Constant)
    ave_power_usage,... % MW (Constant)
    life_span,...       % Years (Constant)
    energy_price,...    % per MWHr (Constant)
    efficiency)       
% mass_per_km, n_conductors and efficiency must be column vectors of equal
% length.
cable_price = AAAC_per_ton/907.2*length*3*n_conductors.*mass_per_km;
P_loss = ave_power_usage*(1 - efficiency)./efficiency;
loss_price = life_span*365*24*energy_price*P_loss;
total_price = cable_price + loss_price;
end