function data = Modulator(freq_samples, Nfft)
    add_values = zeros(size(freq_samples, 1), Nfft - size(freq_samples, 2));
    % первый случай [0, Fs), нули идут после Nc отсчета для каждой поднесущей
    data = [freq_samples, add_values];  

end