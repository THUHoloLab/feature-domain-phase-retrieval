function output = permutohedral( input, sigma_s, sigma_r)
    in_name = sprintf('in%d.png', feature('getpid'));
    out_name = sprintf('out%d.png', feature('getpid'));
    
    imwrite(input, in_name);
    system(sprintf('fast_bf.exe %s %s %f %f', in_name, out_name, sigma_s, sigma_r));
    
    output = im2double(imread(out_name));

%     delete('./*.png');
end

