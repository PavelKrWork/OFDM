function h_omp = omp_on_random_pilots(y_pilot_noisy, A_pilot, L)
    % Оценка канала методом OMP
    [M, Nfft] = size(A_pilot);
    h_omp = zeros(Nfft, 1);
    r = y_pilot_noisy; % Остаток
    support = []; % Инициализация поддержки

    for i = 1:L
        correlations = abs(A_pilot' * r);
        [~, idx] = max(correlations);
        support = [support, idx];
        A_selected = A_pilot(:, support);
        h_temp = pinv(A_selected) * y_pilot_noisy;
        r = y_pilot_noisy - A_selected * h_temp;
    end
    
    h_omp(support) = h_temp;
end