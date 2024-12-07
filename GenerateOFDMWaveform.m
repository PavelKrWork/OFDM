function txWaveform = GenerateOFDMWaveform(N_c, N_fft, N_cp)
    rand_qpsk = 2*(randi(2, N_c, 1) - 1.5) + 2*1j * (randi(2, N_c, 1) - 1.5);
    rand_qpsk = rand_qpsk / sqrt(2);

    symb_f = zeros(N_fft, 1);
    symb_f(1:N_c) = rand_qpsk;

    symb_t = ifft(symb_f);
    txWaveform = [symb_t(end-N_cp+1:end); symb_t];

end