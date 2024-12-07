function random_data = data_scramble(bit_signal)
    % Создадим скрэмблирующую последовательность
    init_seed = [1, 0, 1, 0, 1, 0, 1];
    r = length(init_seed);
    seq_length = 2^r - 1;
    msequence = M_sequence(init_seed, seq_length);
    rng(1)
    
    count = floor(length(bit_signal) / length(msequence));
    random_data = bit_signal;
    
    for i = 1 : count
        random_data((i - 1) * length(msequence) + 1 : i * length(msequence)) = xor(random_data((i - 1) * length(msequence) + 1 : i * length(msequence)), msequence);
    end
    last_ind = count * length(msequence);
    random_data(last_ind : end) = xor(random_data(last_ind : end), msequence(1 : length(bit_signal) - last_ind + 1));

end