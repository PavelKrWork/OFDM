function N = Norm(values) % возвращает норму массива (для созвездий)
    sum = 0;
    for i = 1 : size(values, 2) % size() вернет "кортеж" для комплексных чисел, поэтому берем второй элемент из него
        sum = sum + values(i) * conj(values(i));
    end
    N = sqrt(sum / size(values, 2));
end