function u = imgcrop(x,cropsize)
u = x(cropsize+1:end-cropsize,cropsize+1:end-cropsize);
end