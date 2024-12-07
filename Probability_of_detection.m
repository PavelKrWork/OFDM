function probability = Probability_of_detection(cor, frames_number, frame_length)
    
    header_ind = 1 : frame_length : frames_number * frame_length;
    indexes = zeros(1, frames_number);
    k = 1;

    for i = 1 : frame_length : (frames_number - 1) * frame_length
        win = cor(i : i + frame_length - 1);
        max_value = max(win);
        ind = find(win == max_value);
        indexes(k) = ind(1) + i - 1;
        k = k + 1;
    end

    detection_symb = 0;
    for i = 1 : frames_number
        if indexes(i) == header_ind(i)
            detection_symb = detection_symb + 1;
        end
    end

    probability = detection_symb / frames_number;

end