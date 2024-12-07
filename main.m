%close all;
clearvars -except iExt bettaArr; clc;
%% Transmitter
%% Cчитывание и конвертация изображения в бинарное представление
I = imread('huawei_logo.jpg'); 
bin_img = im2bw(I, 0.7);
imshow(bin_img);
bit_signal = reshape(bin_img, 1, size(bin_img, 1) * size(bin_img, 2));
test_rand = randi(2, 500*500, 1) - 1;

%% Добавим скрэмблер
scrambl_sig = data_scramble(test_rand');
%% Модуляция бинарного сигнала
constell = "16-QAM";
IQ = mapping(scrambl_sig, constell);  % Используем созвездие 16-QAM (разрядность - 4 бита на символ)
%% Формирование OFDM-сигналов
Nc = 500;  % Количество поднесущих
freq_samples = IQ_sampler(IQ, Nc);
%% ОДПФ
Nfft = 1000;  % Количество точек ОДПФ (Nfft > Nc)
% Предобработаем данные перед применением ОДПФ, заполнив нулями недостающие
% ячейки матрицы
% TODO: Под этот код нужно завести функцию модулятора.
% OFDMFreqSamples - не удачное название.  (IQ_sampler)
% Не понятно как формируется полоса. Или это случай [0, Fs) или
% [-Fs/2,Fs/2). Если первый случай, то нули должны разбивать поднесущие
% по середине полосы. Если второй, то полоса из поднесущих разбивает нули 
% на две одинаковые части. На приемной стороне проще получить фильтр для
% обоих случаев

% [0, Fs) -> добавляем нули в конец каждой из поднесущих c Nc по Nfft символы
all_data = Modulator(freq_samples, Nfft); 
% TODO: Изучить help ifft
ifft_data = ifft(all_data,Nfft,2);
%% Добавление циклического префикса
Prefix_period = Nfft / 8;  % длина циклического префикса
OFDM_symbols_prefix = Add_cyclic_prefix(Prefix_period, ifft_data);

%% Выведем АЧХ фильтра приподянтого косинуса
% figure
% % Скрипт для перебора окон
% % bettArr=[1 4 8 32]/(Nfft+Prefix_period); iExt=1;
% % while(iExt<length(bettaArr)) main; end, main
% % i=1;for a=bettaArr, s_leg(i)={num2str(a)}; i=i+1;end
% % legend(s_leg)
% global iExt bettaArr
% iExt = initExt(iExt);
% betta = 1/(Nfft+Prefix_period);
% if ~isempty(bettaArr)
%     betta=bettaArr(iExt);
% end
% y = window_func(betta, Prefix_period + Nfft);
% plot(y)
% xlabel("частота");
% ylabel("амплитуда");
% grid on
%% Произведем сглаживание 
betta1 = 0;
betta2 = 0.04;
Nw1 = betta1 * (Nfft + Prefix_period) + 1;
Nw2 = betta2 * (Nfft + Prefix_period) + 1;
% Создание СР и сглаживание
smooth_OFDM_symbols1 = symbol_smoothing(Prefix_period, betta1, OFDM_symbols_prefix);
smooth_OFDM_symbols2 = symbol_smoothing(Prefix_period, betta2, OFDM_symbols_prefix);
%% Добавим шум к сигналу и найдем вероятность детектирования циклического сдвига от SNR
% % Возмем num копий одного зашумленного символа
% num = 100;
% border = 0.8;  % зададим границу корреляции при которой будем считать вероятность детектирования корректной 
% test_symb = OFDM_symbols_prefix(1, :);
% window_size = Prefix_period - Nw;
% SNR = -10 :0.1: 20;  % dB
% probs = zeros(1, length(SNR));
% for i = 1: length(SNR)
%     count = 0;
%     for j = 1 : num
%         test_noise_symb = NoiseGenerator(test_symb, SNR(i));
%         corr = corr_coeff(test_noise_symb(Nw + 1:Prefix_period), test_noise_symb(end - window_size + 1:end));
%         if corr >= border
%             count = count + 1;
%         end
%     end
%     probs(i) = count / num;
% end
%% Построим график зависимости вероятности детектирования от SNR
% plot(SNR, probs);
% xlabel('SNR');
% ylabel('Probability of detection cyclic prefix');
% grid on;
% xlim([-5 20]);
%% Произведем сшивку символов
stich_symbols1 = symbol_stitching(Nw1, smooth_OFDM_symbols1);
stich_symbols2 = symbol_stitching(Nw2, smooth_OFDM_symbols2);

%%
% spectr_power = pwelch(stich_symbols2);
% x = 1 : length(spectr_power);
% semilogy(x, sectr_power);
%% Построим график СПM
figure;
N = length(stich_symbols1);
% periodogram(stich_symbols, rectwin(N),N,"twosided");
symbol_select = 10:100;
Ns = Nfft+Prefix_period;
%stich_symbols
symbols = reshape(stich_symbols1(1:Ns*100),Ns,[]);
xdft = fft(reshape(symbols(:,symbol_select),1,[]).'.*blackman(numel(symbol_select)*Ns)); 
psdx = (1/(2*pi*N)) * abs(xdft).^2; 
freq = 0:2*pi/N:2*pi-2*pi/N; 

% figure(4)
plot(pow2db(psdx))
% plot(freq/pi,pow2db(psdx)) 
grid on 
title( "Периодограмма с использованием БПФ, betta = 0.08" ) 
xlabel( "Нормализованная частота (\times\pi рад/выборка)" ) 
ylabel( "Мощность/Частота (дБ/(рад/выборка))" )
ylim([-140 -20]);
hold on

%%
figure;
N = length(stich_symbols2);
% periodogram(stich_symbols, rectwin(N),N,"twosided");
symbol_select = 10:100;
Ns = Nfft+Prefix_period;
%stich_symbols
symbols = reshape(stich_symbols2(1:Ns*100),Ns,[]);
xdft = fft(reshape(symbols(:,symbol_select),1,[]).'.*blackman(numel(symbol_select)*Ns)); 
psdx = (1/(2*pi*N)) * abs(xdft).^2; 
freq = 0:2*pi/N:2*pi-2*pi/N; 

% figure(4)
plot(pow2db(psdx))
% plot(freq/pi,pow2db(psdx)) 
grid on 
title( "Периодограмма с использованием БПФ, betta = 0.04" ) 
xlabel( "Нормализованная частота (\times\pi рад/выборка)" ) 
ylabel( "Мощность/Частота (дБ/(рад/выборка))" )
ylim([-140 -20]);
hold on


%%
% betta_values = [0.02, 0.04, 0.06, 0.08];  % Пример значений betta
% Nfft = 64;  % Пример значения Nfft
% Prefix_period = 16;  % Пример значения Prefix_period
% OFDM_symbols_prefix = rand(Nfft + Prefix_period, 1);  % Примерный входной сигнал
% symbol_smoothing = @(prefix, betta, symbols) symbols;  % Заглушка для вашей функции сглаживания
% 
% % Создание графиков для разных betta
% figure;
% hold on;
% for betta = betta_values
%     Nw = betta * (Nfft + Prefix_period) + 1;
% 
%     % Создание сглаженных символов
%     smooth_OFDM_symbols = symbol_smoothing(Prefix_period, betta, OFDM_symbols_prefix); 
% 
%     % Длина данных
%     N = length(smooth_OFDM_symbols);
% 
%     % Выбор символов
%     symbol_select = 10:100;
%     Ns = Nfft + Prefix_period;
% 
%     % Проверка, сколько символов можно взять для reshape
%     max_symbols = floor(N / Ns);  % Максимальное количество символов, которые можно взять из данных
%     total_samples = max_symbols * Ns;  % Общее количество сэмплов, которое можем использовать
% end

%% resample
parallel_data = OFDMFreqSamples(stich_symbols2(1 : length(stich_symbols2) - Nw2), size(OFDM_symbols_prefix, 2));
%% Удаление циклического префикса
freq_samples = Delete_cyclic_prefix(Prefix_period, parallel_data);
%% Преобразуем символы в последовательный сигнал
serial_signal = Serializer(freq_samples, Nfft);
%% Receiver
%% "Нарезаем" последовательный сигнал на символы
parralel_signal = IQ_sampler(serial_signal, Nfft);
%% Применение дробной задержки (SCO)
new_data = fft(parralel_signal, Nfft, 2);

filterLength = 20;
MaximumDelay = 100;    % Максимальная задержка для VFD в выборках
delayVec = 0.5 * randn(size(new_data)); % Задержка от -0.5 до 0.5 выборки для каждого отсчета
% Создание объекта dsp.VariableFractionalDelay
vfd = dsp.VariableFractionalDelay('InterpolationMethod', 'FIR', ...
                                   'FilterHalfLength', filterLength, ...
                                   'MaximumDelay', MaximumDelay);
ofdmWithCPDelayed = vfd(new_data, delayVec);  % Применение задержки
%% Визуализация
figure;
subplot(2,1,1);
plot(real(new_data(50, :)), 'b');
title('Original OFDM Symbol');
xlabel('Sample Index');
ylabel('Amplitude');
xlim([0 510])
grid on;

subplot(2,1,2);
plot(real(ofdmWithCPDelayed(50, :)), 'r');
title('OFDM Symbol with Variable Sampling Clock Offset');
xlabel('Sample Index');
ylabel('Amplitude');
xlim([0 510])
grid on;
%%
% Построить разницу между new_data и all_datа и оценить 
% минимальную оценку epsilon
% max ошибка в разности значений OFDM сигналов на передаче и приеме
epsilon = max(max(abs(new_data - all_data))); 

% TODO:Под этот код нужно завести функцию демодулятора
% Имелось ввиду преобразование полосы. Сейчас название не отражает
% действительность тк несколько операций делаются в одном методе
reciever_bits = data_scramble(Demodulator(new_data, Nc, constell));
% reciever_bits = data_scramble(reciever_bits);
reciever_img = reshape(reciever_bits, size(bin_img));
figure
imshow(reciever_img);
%% Подсчитаем BER
BER = Error_check(bit_signal, reciever_bits);
disp(["Количество неверно принятых бит равно: ", BER(1)]);
disp(["Вероятность ошибки на бит равна: ", BER(2)]);

iExt = mod(iExt,numel(bettaArr))+1;
function v = initExt(v)
    if isempty(v)
        v = 1;
    end
end