function data = OFDMFreqSamples(IQ_samples, Nc)
    % Nc - number of subcarriers
    if mod(length(IQ_samples), Nc) ~= 0
        disp("The length of the sequence of iq points is not a multiple of the number of subcarriers");
        return;
    end

    data = zeros(length(IQ_samples) / Nc, Nc);
    count = 1;
    for i = 1 : Nc : length(IQ_samples)
        data(count, :) = IQ_samples(i : Nc + i - 1);
        count = count + 1;
    end
end