clear; clc;
%% Let's generate LTE channel
N_c = 400;
N_fft = 1024;
N_cp = N_fft/8;
txWaveform = GenerateOFDMWaveform(N_c, N_fft, N_cp);

channel.Seed = 2;
channel.NRxAnts = 1;
channel.DelayProfile = 'EVA';
channel.DopplerFreq = 0;
channel.MIMOCorrelation = 'Low';
channel.SamplingRate = 10e6;
channel.InitTime = 0;
channel.NormalizePathGains = 'On';

[rxWaveform, info] = lteFadingChannel(channel,txWaveform);
rxWaveform = rxWaveform / norm(rxWaveform, 'fro') * norm(txWaveform, 'fro');

% % Power Delay Profile of the Channel
% figure(1)
% stem(info.PathSampleDelays, abs(info.PathGains(1, :)).^2, 'LineWidth', 2)
% xlabel('Delays in samples')
% ylabel('CIR power')
% title (strcat('EVA, seed', 32, num2str(channel.Seed)))
% set(gca, 'FontSize', 20)
% grid on

%% performing channel estimation (suppose all subcarriers are pilot subcarriers)

yrx_windowed = rxWaveform(1+N_cp:end);
ytx_windowed = txWaveform(1+N_cp:end);

yF_rx_windowed = fft(yrx_windowed); % received signal
yF_tx_windowed = fft(ytx_windowed); % ideal pilots

% our LS channel estimate
H_hat = yF_rx_windowed(1:N_c) ./ yF_tx_windowed(1:N_c);

% figure(2)
% plot(abs(H_hat))
% hold off
% xlabel('DFT bins')
% ylabel('Channel Frequency responce')
% set(gca, 'FontSize', 20)
% grid on
%%
% Расчет мощности по поднесущим
power_rx = abs(yF_rx_windowed(1:N_c)).^2; % Мощность по поднесущим для принятого сигнала
power_tx = abs(yF_tx_windowed(1:N_c)).^2; % Мощность по поднесущим для переданного сигнала

% Построение графика распределения мощности по поднесущим
figure
subplot(2,1,1)
stem(0:N_c-1, power_rx, 'LineWidth', 2)
xlabel('Поднесущая')
ylabel('Мощность (Принятый сигнал)')
title('Распределение мощности по поднесущим (Принятый сигнал)')
grid on

subplot(2,1,2)
stem(0:N_c-1, power_tx, 'LineWidth', 2)
xlabel('Поднесущая')
ylabel('Мощность (Переданный сигнал)')
title('Распределение мощности по поднесущим (Переданный сигнал)')
grid on

%% Используем водоналивной алгоритм
epsilon = 10^-3;
% Спектральная мощность плотности шума
N0 = mean(abs(fft(abs(power_tx - power_rx))));
P_mean = mean(power_rx);

res = water_filled_algoritm(H_hat, power_tx, N_c, P_mean, N0, epsilon);

%% Подсчет пропускной способности 
% Ts = 1 -> fs = 1
capacity_uniform = capacity(H_hat, power_tx, N_c, N0);  % Для равномерного распределения мощностей
capacity_water_fill = capacity(H_hat, res, N_c, N0);

fprintf('Capacity with uniform distribution: %f\n', capacity_uniform);
fprintf('Capacity with water filling algoritm: %f\n', capacity_water_fill);

if capacity_water_fill > capacity_uniform
    fprintf('the gain by capacity is: %f\n', capacity_water_fill - capacity_uniform);
else
    error('unpredictable behavior');
end

%% усредним пропускную способность по 100 реализациям канала
Count = 100;
%% EVA
capacity_uniform1 = 0;
capacity_water_fill1 = 0;

for i = 1 : Count
    channel.Seed = i;
    channel.NRxAnts = 1;
    channel.DelayProfile = 'EVA';
    channel.DopplerFreq = 0;
    channel.MIMOCorrelation = 'Low';
    channel.SamplingRate = 10e6;
    channel.InitTime = 0;
    channel.NormalizePathGains = 'On';

    [rxWaveform, info] = lteFadingChannel(channel,txWaveform);
    rxWaveform = rxWaveform / norm(rxWaveform, 'fro') * norm(txWaveform, 'fro');

    yrx_windowed = rxWaveform(1+N_cp:end);
    ytx_windowed = txWaveform(1+N_cp:end);
    
    yF_rx_windowed = fft(yrx_windowed); % received signal
    yF_tx_windowed = fft(ytx_windowed); % ideal pilots
    
    % our LS channel estimate
    H_hat = yF_rx_windowed(1:N_c) ./ yF_tx_windowed(1:N_c);
    
    power_rx = abs(yF_rx_windowed(1:N_c)).^2; % Мощность по поднесущим для принятого сигнала
    power_tx = abs(yF_tx_windowed(1:N_c)).^2; % Мощность по поднесущим для переданного сигнала

    epsilon = 10^-3;

    % Спектральная мощность плотности шума
    N0 = mean(abs(fft(abs(power_tx - power_rx))));
    P_mean = mean(power_rx);
    
    res = water_filled_algoritm(H_hat, power_tx, N_c, P_mean, N0, epsilon);
    
    capacity_uniform1 = capacity_uniform1 + capacity(H_hat, power_tx, N_c, N0);  % Для равномерного распределения мощностей
    capacity_water_fill1 = capacity_water_fill1 + capacity(H_hat, res, N_c, N0);  % Для водоналивного алгоритма

end

capacity_uniform1 = capacity_uniform1 / Count;
capacity_water_fill1 = capacity_water_fill1 / Count;

fprintf('Capacity with uniform distribution: %f\n', capacity_uniform1);
fprintf('Capacity with water filling algoritm: %f\n', capacity_water_fill1);

%% EPA
capacity_uniform2 = 0;
capacity_water_fill2 = 0;

for i = 1 : Count
    channel.Seed = i;
    channel.NRxAnts = 1;
    channel.DelayProfile = 'EPA';
    channel.DopplerFreq = 0;
    channel.MIMOCorrelation = 'Low';
    channel.SamplingRate = 10e6;
    channel.InitTime = 0;
    channel.NormalizePathGains = 'On';

    [rxWaveform, info] = lteFadingChannel(channel,txWaveform);
    rxWaveform = rxWaveform / norm(rxWaveform, 'fro') * norm(txWaveform, 'fro');

    yrx_windowed = rxWaveform(1+N_cp:end);
    ytx_windowed = txWaveform(1+N_cp:end);
    
    yF_rx_windowed = fft(yrx_windowed); % received signal
    yF_tx_windowed = fft(ytx_windowed); % ideal pilots
    
    % our LS channel estimate
    H_hat = yF_rx_windowed(1:N_c) ./ yF_tx_windowed(1:N_c);
    
    power_rx = abs(yF_rx_windowed(1:N_c)).^2; % Мощность по поднесущим для принятого сигнала
    power_tx = abs(yF_tx_windowed(1:N_c)).^2; % Мощность по поднесущим для переданного сигнала

    epsilon = 10^-3;

    % Спектральная мощность плотности шума
    N0 = mean(abs(fft(abs(power_tx - power_rx))));
    P_mean = mean(power_rx);
    
    res = water_filled_algoritm(H_hat, power_tx, N_c, P_mean, N0, epsilon);
    
    capacity_uniform2 = capacity_uniform2 + capacity(H_hat, power_tx, N_c, N0);  % Для равномерного распределения мощностей
    capacity_water_fill2 = capacity_water_fill2 + capacity(H_hat, res, N_c, N0);  % Для водоналивного алгоритма

end

capacity_uniform2 = capacity_uniform2 / Count;
capacity_water_fill2 = capacity_water_fill2 / Count;

fprintf('Capacity with uniform distribution: %f\n', capacity_uniform2);
fprintf('Capacity with water filling algoritm: %f\n', capacity_water_fill2);

%% ETU
capacity_uniform3 = 0;
capacity_water_fill3 = 0;

for i = 1 : Count
    channel.Seed = i;
    channel.NRxAnts = 1;
    channel.DelayProfile = 'ETU';
    channel.DopplerFreq = 0;
    channel.MIMOCorrelation = 'Low';
    channel.SamplingRate = 10e6;
    channel.InitTime = 0;
    channel.NormalizePathGains = 'On';

    [rxWaveform, info] = lteFadingChannel(channel,txWaveform);
    rxWaveform = rxWaveform / norm(rxWaveform, 'fro') * norm(txWaveform, 'fro');

    yrx_windowed = rxWaveform(1+N_cp:end);
    ytx_windowed = txWaveform(1+N_cp:end);
    
    yF_rx_windowed = fft(yrx_windowed); % received signal
    yF_tx_windowed = fft(ytx_windowed); % ideal pilots
    
    % our LS channel estimate
    H_hat = yF_rx_windowed(1:N_c) ./ yF_tx_windowed(1:N_c);
    
    power_rx = abs(yF_rx_windowed(1:N_c)).^2; % Мощность по поднесущим для принятого сигнала
    power_tx = abs(yF_tx_windowed(1:N_c)).^2; % Мощность по поднесущим для переданного сигнала

    epsilon = 10^-3;

    % Спектральная мощность плотности шума
    N0 = mean(abs(fft(abs(power_tx - power_rx))));
    P_mean = mean(power_rx);
    
    res = water_filled_algoritm(H_hat, power_tx, N_c, P_mean, N0, epsilon);
    
    capacity_uniform3 = capacity_uniform3 + capacity(H_hat, power_tx, N_c, N0);  % Для равномерного распределения мощностей
    capacity_water_fill3 = capacity_water_fill3 + capacity(H_hat, res, N_c, N0);  % Для водоналивного алгоритма

end

capacity_uniform3 = capacity_uniform3 / Count;
capacity_water_fill3 = capacity_water_fill3 / Count;

fprintf('Capacity with uniform distribution: %f\n', capacity_uniform3);
fprintf('Capacity with water filling algoritm: %f\n', capacity_water_fill3);

%% Гистограмма для моделей EVA, EPA, ETU
capacities = [capacity_uniform1 capacity_water_fill1; capacity_uniform2 capacity_water_fill2; capacity_uniform3 capacity_water_fill3];

bar(capacities, 'grouped');
grid on;
ylabel('пропускная способность (Бит / c)');
legend({'равномерное распределение мощностей', 'водоналивной алгоритм'});
set(gca, 'XTickLabel', {'EVA', 'EPA', 'ETU'});