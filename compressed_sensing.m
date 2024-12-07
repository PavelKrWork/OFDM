%close all; 
clearvars -except iExt bettaArr; clc;

%% Transmitter
I = imread('huawei_logo.jpg'); 
bin_img = im2bw(I, 0.7);
imshow(bin_img);
bit_signal = reshape(bin_img, 1, size(bin_img, 1) * size(bin_img, 2));

%% Scrambling
scrambl_sig = data_scramble(bit_signal);

%% Modulation
constell = "16-QAM";
IQ = mapping(scrambl_sig, constell);

%% OFDM Signal Formation
Nc = 500; % Number of subcarriers
freq_samples = IQ_sampler(IQ, Nc);

%% Adding pilots and modulation
Nfft = 1000; % FFT points
num_pilots = 100; % Number of pilot subcarriers
pilot_power = 1; % Power of pilot signals
[all_data_with_pilots, pilot_indices] = add_pilots(freq_samples, Nfft, num_pilots, pilot_power);

ifft_data = ifft(all_data_with_pilots, Nfft, 2);

%% Adding cyclic prefix
Prefix_period = Nfft / 8; 
OFDM_symbols_prefix = Add_cyclic_prefix(Prefix_period, ifft_data);

%% Adding noise
SNR_dB = 20;
noisy_signal = NoiseGenerator(OFDM_symbols_prefix, SNR_dB);

%% Receiver: Channel Estimation
% Random sparse channel
L = 50; % Number of significant taps
h_true = zeros(Nfft, 1);
support = randperm(Nfft, L);
h_true(support) = randn(L, 1) + 1j * randn(L, 1);

% Pilots received
A_pilot = fft(eye(Nfft));
A_pilot = A_pilot(pilot_indices, :);
y_pilot_noisy = A_pilot * h_true + ...
    sqrt(0.5/SNR_dB) * (randn(num_pilots, 1) + 1j * randn(num_pilots, 1));

% LS estimation
h_ls = pinv(A_pilot) * y_pilot_noisy;

% OMP estimation
h_omp = omp_on_random_pilots(y_pilot_noisy, A_pilot, L);

% NMSE
NMSE_LS = norm(h_true - h_ls)^2 / norm(h_true)^2;
NMSE_OMP = norm(h_true - h_omp)^2 / norm(h_true)^2;

disp(['NMSE LS: ', num2str(NMSE_LS)]);
disp(['NMSE OMP: ', num2str(NMSE_OMP)]);
%%
%%
close all; 
clearvars -except iExt bettaArr; clc;

%% Параметры
Nfft = 1000; % Количество поднесущих
L = 50; % Число значительных отсчетов канала
SNR_dB = 20; % Уровень шума в дБ
num_trials = 50; % Число экспериментов для усреднения
pilot_ratios = 0.05:0.05:0.5; % Доли пилотов от общего числа поднесущих

% Истинный канал
h_true = zeros(Nfft, 1);
support = randperm(Nfft, L);
h_true(support) = randn(L, 1) + 1j * randn(L, 1);

% Результаты NMSE
NMSE_LS = zeros(length(pilot_ratios), 1);
NMSE_OMP = zeros(length(pilot_ratios), 1);

%% Главный цикл по числу пилотов
for idx = 1:length(pilot_ratios)
    num_pilots = round(pilot_ratios(idx) * Nfft);
    errors_LS = zeros(num_trials, 1);
    errors_OMP = zeros(num_trials, 1);
    
    for trial = 1:num_trials
        % Случайное размещение пилотов
        pilot_indices = randperm(Nfft, num_pilots);
        pilot_values = (randn(num_pilots, 1) + 1j * randn(num_pilots, 1)) / sqrt(2);
        
        % Матрица пилотов
        A_pilot = fft(eye(Nfft));
        A_pilot = A_pilot(pilot_indices, :);
        
        % Наблюдения с шумом
        y_pilot_noisy = A_pilot * h_true + ...
            sqrt(0.5 / SNR_dB) * (randn(num_pilots, 1) + 1j * randn(num_pilots, 1));
        
        % LS оценка
        h_ls = pinv(A_pilot) * y_pilot_noisy;
        errors_LS(trial) = norm(h_true - h_ls)^2 / norm(h_true)^2;
        
        % OMP оценка
        h_omp = omp_on_random_pilots(y_pilot_noisy, A_pilot, L);
        errors_OMP(trial) = norm(h_true - h_omp)^2 / norm(h_true)^2;
    end
    
    % Усреднение ошибок
    NMSE_LS(idx) = mean(errors_LS);
    NMSE_OMP(idx) = mean(errors_OMP);
end

%% Построение графиков
figure;
plot(pilot_ratios * 100, 10 * log10(NMSE_LS), '-o', 'LineWidth', 2, 'DisplayName', 'LS');
hold on;
plot(pilot_ratios * 100, 10 * log10(NMSE_OMP), '-s', 'LineWidth', 2, 'DisplayName', 'OMP');
grid on;
xlabel('Percentage of Pilots (%)');
ylabel('NMSE (dB)');
legend('Location', 'Best');
title('NMSE vs. Number of Pilots');

