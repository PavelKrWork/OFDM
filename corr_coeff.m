function corr_coeff = corr_coeff(signal1, signal2)
    % Проверяем, что сигналы имеют одинаковую длину
    N = length(signal1);
    if length(signal2) ~= N
        error('Signals must be of the same length.');
    end
    
    % Вычисляем числитель корреляции как сумму произведений элементов сигналов
    numerator = sum(signal1 .* conj(signal2));
    
    % Вычисляем знаменатель как произведение корней из сумм квадратов амплитуд
    denominator = sqrt(sum(abs(signal1).^2) * sum(abs(signal2).^2));
    
    % Вычисляем нормализованный коэффициент корреляции
    corr_coeff = numerator / denominator;
    
    % Нормализуем результат так, чтобы его максимум был равен 1
    corr_coeff = abs(corr_coeff);
end
