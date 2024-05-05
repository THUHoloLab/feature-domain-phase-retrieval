function output = cmedfilt2(input, ksize)
    output = zeros(size(input));
    for i = 1 : size(input, 3)
        output(:,:,i) = medfilt2(input(:,:,i), ksize);
    end
    output = im2double(output);
end

