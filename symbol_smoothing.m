function smooth_OFDM_symbols = symbol_smoothing(Prefix_period, betta, OFDM_symbols_prefix)
    [num_rows, num_cols] = size(OFDM_symbols_prefix);
    Ts = num_cols;
    smooth_OFDM_symbols = zeros(num_rows, Ts*(1 + betta) + 1);
    for i = 1 : num_rows
        smooth_OFDM_symbols(i, 1 : num_cols) = OFDM_symbols_prefix(i, :);
        smooth_OFDM_symbols(i, num_cols + 1 : end) = OFDM_symbols_prefix(i, Prefix_period : Prefix_period + betta*num_cols);
    end
    
    for i = 1 : num_rows
        smooth_OFDM_symbols(i, :) = smooth_OFDM_symbols(i, :).*window_func(betta, Ts);
    end
    
end