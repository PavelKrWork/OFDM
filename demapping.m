function Bit = demapping(IQ, Constellation)
% Make the different dictionary for BPSK, QPSK, 8PSK, 16QAM constellations
% calculate the Bit_depth for each contellation
[Dictionary, Bit_depth_Dict] = constellation_func(Constellation);

% write  the function of mapping from IQ vector to bit vector
new_Dictionary = dictionary(values(Dictionary), keys(Dictionary));

cv = values(Dictionary);  % constellation_values
bit_array = [];
for i = 1 : length(IQ)
    t_min = realmax;

    % we need to find constellation point with min distance
    I_min = 0;
    Q_min = 0;

    for j = 1 : length(cv)
        t = sqrt((real(IQ(i)) - real(cv(j)))^2 + (imag(IQ(i)) - imag(cv(j)))^2);
        if (t < t_min)
            t_min = t;
            I_min = real(cv(j));
            Q_min = imag(cv(j));
        end
    end

    symbol = str2num(new_Dictionary(complex(I_min, Q_min)));  % bits(symbol) in array format
    bit_array = [bit_array, symbol];

end

Bit = bit_array;

end

