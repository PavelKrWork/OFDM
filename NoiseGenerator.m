% function NoisedSignal = NoiseGenerator(signal, SNR)
%     % Мощность сигнала
%     P_sig = PowerSignal(signal);
%     % Определим амплитуду шума 
%     A_noise = sqrt(P_sig / 10 ^(SNR / 10));
%     NoiseRe = A_noise * normrnd(0, 1, [1, length(signal)]);
%     NoiseIm = A_noise * normrnd(0, 1, [1, length(signal)]);
%     Noise = complex(NoiseRe, NoiseIm);
%     NoisedSignal = signal + Noise;
% end
function noisy_signal = NoiseGenerator(signal, SNR_dB)
    % Генерация шума с заданным SNR
    SNR = 10^(SNR_dB/10);
    signal_power = mean(abs(signal).^2, 'all');
    noise_power = signal_power / SNR;
    noisy_signal = signal + sqrt(noise_power/2) * ...
        (randn(size(signal)) + 1j * randn(size(signal)));
end
