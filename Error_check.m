function [BER] = Error_check(Bit_Tx, Bit_Rx)
    if length(Bit_Tx) ~= length(Bit_Rx)
        error('Входные векторы имеют разную длину');
    end
    
    error_count = sum(Bit_Tx ~= Bit_Rx);
    error_probability = error_count / length(Bit_Tx);

    BER = [error_count, error_probability];
end

