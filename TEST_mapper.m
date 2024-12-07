% TODO: Не проходит проверка скрипта:

% Domashneye zadaniye №1. Otobrazheniye bit na sozvezdiye.
%> @file hw1.m
% Ispol'zuyemyye fayly: mapping.m (shablon dlya funktsii otobrazheniya bit na sozvezdiye).
% Zadaniye: napisat' ne ispol'zuya standartnyye funktsii i ob"yekty, takiye kak 
% pskmod, apskmod, qammod,comm.[tip modulyatsii]Modulator i t.d.
% Ispol'zuyte fayl mapping.m, kak osnovu dlya funktsii.
% Dannyy fayl sluzhit dlya testirovaniya vashey funktsii.
% Vnimaniye: vo izbzhaniye oshibok obratite vnimaniye na raznitsu rezul'tatov
% funktsiy dec2bin i de2bi. Schitayem, chto starshiy bit v peredavayemoy 
% posdelovatel'nosti zapisan pervym. 
% Dlya prokhozhdeniya testov numeratsiya sozvezdiy dolzhna sovpadat' s
% propisannnoy v zadanii
% =========================================================================
%> Podgotovka rabochego mesta
% =========================================================================
%> Otchistka workspace
clear all;
%> Zakrytiye risunkov
close all;
%> Otchistka Command Window
clc;
% =========================================================================
%> Proverka sozvezdiy
% =========================================================================
% Proverka osushchestvlyayetsya standartnymi funktsiyami demodulyatsii
for constellation = 1:5
    switch (constellation)
        case 1 % BPSK  
            BitInSym = 1;                 % kollichestvo bit na tochku
            ConstName = 'BPSK';
            demod = comm.BPSKDemodulator; % standartnyy demodulyator
        case 2 % QPSK
            BitInSym = 2;                 % kollichestvo bit na tochku
            ConstName = 'QPSK';
            demod = comm.QPSKDemodulator; % standartnyy demodulyator
        case 3 % 8PSK
            BitInSym = 3;                 % kollichestvo bit na tochku
            ConstName = '8PSK';
            demod = comm.PSKDemodulator('ModulationOrder', 8); % standartnyy demodulyator
%         case 4 % 16APSK
%             BitInSym = 4;
%             ConstName = '16-APSK';
%             % do versii 2018a net standartnogo demodulyatora, poetomu tut
%             % poka proverim vizual'no
        case 5 % 16QAM
            BitInSym = 4;
            ConstName = '16-QAM';
    end
%> Proveryayem raspolozheniye tochek na sozvezdii
    data = (0:2^BitInSym-1);
    bits = de2bi(data, BitInSym);
    bits = reshape(bits(:,end:-1:1).', 1, []);
    modData = mapping(bits, ConstName);

    %> Vizualizatsiya
    scatterplot(modData)
    text(real(modData)+0.1, imag(modData), dec2bin(data))
    title(ConstName)
    axis([-2 2 -2 2])
    %> Schitayem srednyuyu moshchnost' (proverka normirovki)
    P = sum(modData.*conj(modData))/length(modData);
    if abs(1-P)>0.00001
        Error = 'Proverte normirovku sozvezdiya'
        disp(Error)
        ConstName = ConstName
    end
    if constellation < 4
        %> Demoduliruyem standartnym demodulyatorom
        bits = randi([0 1], 1, 120000); % generatsiya bit
        modData = mapping(bits, ConstName);
        checkData = demod(modData.');
        checkBits = de2bi(checkData, BitInSym);
        % checkBits = reshape(checkBits(:,end:-1:1).', 1, []);
        checkBits = reshape(checkBits', [], 1)';
        Nerr = sum(xor(checkBits,bits));
        if Nerr~= 0
            Error = 'Proverte sozvezdiye';
            ConstName = ConstName;
        end
    elseif constellation == 5
        %> Demoduliruyem standartnym demodulyatorom
        bits = randi([0 1], 1, 120000); % generatsiya bit
        modData = mapping(bits, ConstName);
        norm = sqrt(10);
        modData = norm*modData;
        %modData = qammod(bits, 16);
        checkData = qamdemod(modData.', 16);
        %checkData = qamdemod(modData, 16);%.', 16);
        checkBits = de2bi(checkData, BitInSym);
        checkBits = reshape(checkBits(:,end:-1:1).', 1, []);
        Nerr = sum(xor(checkBits,bits));
        if Nerr~= 0
            Error = 'Proverte sozvezdiye';
            ConstName = ConstName;
        end
    end
end