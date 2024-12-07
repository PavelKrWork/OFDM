function OFDM_symbols_prefix = Add_cyclic_prefix(Prefix_period, freq_samples)
    [num_rows, num_cols] = size(freq_samples);
    OFDM_symbols_prefix = zeros(num_rows, num_cols + Prefix_period);

    for i = 1 : num_rows
        OFDM_symbols_prefix(i, 1 : Prefix_period) = freq_samples(i, num_cols - Prefix_period + 1:num_cols);
        OFDM_symbols_prefix(i, Prefix_period + 1 : end) = freq_samples(i, :);
    end
end