function out=qx_tree_filter(in,guidance,sigma_r,nonlocal)
    %%guidance: an unsigned char RGB image in [0,255]
    %out: double data type (in [0,255])
    if (~exist('sigma_r','var'))
       sigma_r=0.1;
    end   
    if (~exist('nonlocal','var'))
       nonlocal=1;
    end   
    [h,w,nr_channel]=size(guidance);
    out=double(zeros(size(in)));
    if(nr_channel==3)
tic        
        qx_tree_filter_mex(out,double(in),sigma_r,uint8(guidance),nonlocal);
toc        
    end
end