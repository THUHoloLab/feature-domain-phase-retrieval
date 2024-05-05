function output  = cbilateralFilter(input, sigma_s, sigma_r)
    output = zeros(size(input));
    
    for i = 1 : size(input, 3)
        output(:,:,i) = bilateralFilter(input(:,:,i), [],[],[],sigma_s, sigma_r);
    end
    output = im2double(output);
end

