function wind_array = window_func(betta, Ts)
    wind_array = zeros(1, (1 + betta)*Ts + 1);
    for n = 1 : betta*Ts + 1
        wind_array(n) = 0.5 + 0.5 * cos(pi + n * pi / (betta * Ts));
    end
    wind_array(betta*Ts + 1 : Ts + 1) = 1;
    for n = Ts + 1 : (1 + betta)*Ts + 1
        wind_array(n) = 0.5 + 0.5 * cos((n - Ts) * pi / (betta * Ts));
    end
end