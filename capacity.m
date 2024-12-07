function spef = capacity(channel, power_distr, Nc, N0)
    spef = 0;
    for k = 1 : Nc
        spef = spef + log2(1 + abs(channel(k))^2 * power_distr(k) / N0);
    end
end