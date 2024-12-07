function IQ_samples = symbol_stitching(Nw, smooth_OFDM_symbols)
    [num_rows, num_cols] = size(smooth_OFDM_symbols);
    IQ_samples = zeros(1, num_rows * num_cols - (num_rows - 1) * Nw);
    IQ_samples(1 : num_cols) = smooth_OFDM_symbols(1, :);
    for i = 1 : num_rows - 1
        IQ_samples((num_cols - Nw)*i + 1 : i*num_cols - (i - 1)*Nw) = IQ_samples((num_cols - Nw)*i + 1 : i*num_cols - (i - 1)*Nw) + smooth_OFDM_symbols(i + 1, 1 : Nw);
        IQ_samples(i*num_cols - (i - 1)*Nw + 1 : (num_cols - Nw)*(i + 1)) = smooth_OFDM_symbols(i + 1, Nw + 1 : num_cols - Nw);
    end
end
% function IQ_samples = symbol_stitching(Nw, smooth_OFDM_symbols)
%     [num_rows, num_cols] = size(smooth_OFDM_symbols);
% 
%     % Размер итогового массива
%     IQ_samples = zeros(1, num_rows * num_cols - (num_rows - 1) * Nw);
% 
%     % Копирование первого ряда в IQ_samples
%     IQ_samples(1:num_cols) = smooth_OFDM_symbols(1, :);
% 
%     % Объединение символов с учётом перекрытия
%     for i = 1:num_rows - 1
%         % Индексация для добавления перекрытия
%         start_idx = (num_cols - Nw) * (i - 1) + 1;
%         end_idx = start_idx + num_cols - Nw - 1;
%         IQ_samples(start_idx:end_idx) = IQ_samples(start_idx:end_idx) + smooth_OFDM_symbols(i + 1, 1:Nw);
% 
%         % Индексация для добавления оставшейся части
%         start_idx = end_idx + 1;
%         end_idx = start_idx + num_cols - Nw - 1;
%         IQ_samples(start_idx:end_idx) = smooth_OFDM_symbols(i + 1, Nw + 1:end);
%     end
% end
