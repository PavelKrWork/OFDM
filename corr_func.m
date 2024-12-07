function normalized_corr = corr_func(signal1, signal2)
    % corr = abs(dot(sig1, conj(sig2)) / sqrt(sum(abs(sig1).^2) * sum(abs(sig2).^2)));
    % Проверяем, что сигналы имеют одинаковую длину
    N = length(signal1);
    if length(signal2) ~= N
        error('Signals must be of the same length.');
    end
    
    % Вычисляем кросс-корреляцию вручную
    cross_corr = zeros(1, 2*N - 1);
    for k = -N+1:N-1
        shift = max(1, 1 - k):min(N, N - k);
        cross_corr(k + N) = sum(signal1(shift) .* conj(signal2(shift + k)));
    end
    
    % Вычисляем авто-корреляцию для нормализации
    auto_corr1 = sum(abs(signal1).^2);
    auto_corr2 = sum(abs(signal2).^2);
    
    % Нормализуем кросс-корреляцию
    normalization_factor = sqrt(auto_corr1 * auto_corr2);
    normalized_corr = cross_corr / normalization_factor;
end