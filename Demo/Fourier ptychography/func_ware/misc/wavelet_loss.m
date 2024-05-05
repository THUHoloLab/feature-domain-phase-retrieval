function [loss,out] = wavelet_loss(dW,level,type)
loss = 0;

[m,n,ch] = size(dW);
out = gpuArray(single(zeros(m,n,ch)));
for channel = 1:ch
    [c,s] = wavedec2(dW(:,:,channel),level,type);
    out(:,:,channel) = waverec2(sign(c),s,type);
    loss = loss + mean(abs(c(:)));
end

end