function Average_Power = PowerSignal(signal)
    Average_Power = mean(abs(signal).^2);
end