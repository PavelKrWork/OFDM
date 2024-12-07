function power_distr = water_filled_algorithm(H_hat, init_power_distr, Nc, P_mean, N0, epsilon)
    % Инициализация
    power_distr = zeros(1, length(init_power_distr)); % Массив мощностей
    alpha_left = 0; % Нижняя граница
    alpha_right = P_mean; % Верхняя граница
    
    % Расчёт верхней границы для alpha
    for i = 1:Nc
        alpha_right = alpha_right + N0 / abs(H_hat(i))^2;
    end
    
    num = 0;
    % бинарный поиск по alpha - O(log(n)), n - размер данных поиска
    while true
        % Обновляем alpha как среднее между верхней и нижней границами
        alpha = (alpha_left + alpha_right) / 2;

        % Вычисление распределения мощности
        for k = 1:length(init_power_distr)
            power_distr(k) = max(0, alpha - N0 / abs(H_hat(k))^2);
        end

        % Проверка разницы между рассчитанной и требуемой мощностью
        total_power = sum(power_distr);
        error = abs(Nc * P_mean - total_power);
        
        % Если ошибка меньше порога, выходим из цикла
        if error < epsilon
            break;
        end

        % Регулируем границы alpha
        if total_power < Nc * P_mean
            alpha_left = alpha; % Увеличиваем нижнюю границу
        else
            alpha_right = alpha; % Уменьшаем верхнюю границу
        end

        fprintf('iteration number: %d\n', num);
        num = num + 1;

    end
    fprintf('Totally iterations: %d\n', num);
end
