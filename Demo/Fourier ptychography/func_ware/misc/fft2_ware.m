function y = fft2_dl(x,if_shift)

if if_shift
    y =  fftshift(fftshift(fft(fft(x,[],2),[],1),1),2);
else
    y = fft(fft(x,[],2),[],1);
end

end