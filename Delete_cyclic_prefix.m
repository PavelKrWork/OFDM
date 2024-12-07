function OFDM_symbols = Delete_cyclic_prefix(Prefix_period, freq_samples_prefix)
    [num_rows, num_cols] = size(freq_samples_prefix);
    OFDM_symbols = zeros(num_rows, num_cols - Prefix_period);

    for i = 1 : num_rows
        OFDM_symbols(i, :) = freq_samples_prefix(i, Prefix_period + 1 : end);
    end
end