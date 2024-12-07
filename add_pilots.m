function [signal_with_pilots, pilot_indices] = add_pilots(freq_samples, Nfft, num_pilots, pilot_power)
    % Добавление пилотов в OFDM сигнал
    [num_symbols, Nc] = size(freq_samples);  % Число символов и поднесущих
    signal_with_pilots = zeros(num_symbols, Nfft);  % Создаём матрицу под OFDM сигнал с пилотами

    % Генерация случайных индексов для пилотов
    pilot_indices = sort(randperm(Nfft, num_pilots));
    
    % Распределение индексов для данных
    data_indices = setdiff(1:Nfft, pilot_indices); 
    data_indices = data_indices(1:Nc);  % Берём только Nc индексов для данных
    
    % Добавление пилотов
    signal_with_pilots(:, pilot_indices) = sqrt(pilot_power) * ones(num_symbols, num_pilots);

    % Добавление данных
    signal_with_pilots(:, data_indices) = freq_samples;
end
