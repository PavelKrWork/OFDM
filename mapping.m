function IQ = mapping(Bit_Tx, Constellation)
% Make the different dictionary for BPSK, QPSK, 8PSK, 16QAM constellations
% calculate the Bit_depth for each contellation

% Dictionary - points of Constellation
% TODO: Не проходит тест нужно поправить функцию. Тест внутри функции
[Dictionary, Bit_depth_Dict] = constellation_func(Constellation);

% write  the function of mapping from bit vector to IQ vector

% Future complex points
Points = zeros(length(Bit_Tx) / Bit_depth_Dict, 1)';
k=1;
% Points = [];
for i = 1 : Bit_depth_Dict : length(Bit_Tx) - Bit_depth_Dict + 1
    key = num2str(Bit_Tx(i:i + Bit_depth_Dict - 1));
    point = Dictionary(key);  % complex point
% Плохой стиль, память под объект выделяется внутри цикла
%     Points = [Points, point];
% Так правильно
    Points(k) = point;
    k=k+1;
end

IQ = Points;

end

