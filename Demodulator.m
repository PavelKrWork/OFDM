function reciever_bits = Demodulator(reciever_data, Nc, constell)
    % Serializer + demapping
    reciever_sig = Serializer(reciever_data, Nc);
    reciever_bits = demapping(reciever_sig, constell);
end