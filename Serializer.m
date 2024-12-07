function serial_data = Serializer(parallel_data, len)
    height = size(parallel_data, 1);
    serial_data = zeros(1, height * len);

    for i = 1 : height
        serial_data(len * (i - 1) + 1 : len * i) = parallel_data(i, 1 : len);
    end

end