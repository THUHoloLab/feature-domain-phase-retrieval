function [loss,dldw1,dldw2] = fpm_forward(wavefront1, ...
                                                wavefront2, ...
                                                b_ledpos, ...
                                                dY_obs, ...
                                                pratio, ...
                                                type)



dldw1 = 0*wavefront1;
sub_wavefront1 = dY_obs;

%% forward inference
ft_wavefront1 = fft2_ware(wavefront1,true);
for data_con = 1:size(dY_obs,3)
    kt = b_ledpos(data_con,3);
    kb = b_ledpos(data_con,4);
    kl = b_ledpos(data_con,1);
     kr = b_ledpos(data_con,2);
    sub_wavefront1(:,:,data_con) = ft_wavefront1(kt:kb,kl:kr);
end
x = ifft2_ware(sub_wavefront1 .* wavefront2,true) / pratio^2;

[loss,dm] = ret_loss(abs(x) - dY_obs,'isotropic');
x           =   dm .* sign(x) * pratio^2; %

%% backward propagation
x_record    =   fft2_ware(x,true);
x           =   deconv_pie(x_record,wavefront2,type);

for data_con = 1:size(dY_obs,3)
    kt = b_ledpos(data_con,3);
    kb = b_ledpos(data_con,4);
    kl = b_ledpos(data_con,1);
    kr = b_ledpos(data_con,2);
    dldw1(kt:kb,kl:kr) = dldw1(kt:kb,kl:kr) + x(:,:,data_con);
end

dldw1 = ifft2_ware(dldw1,true);
dldw2 = sum(deconv_pie(x_record,sub_wavefront1,type),3);

end

function out = deconv_pie(in,ker,type)
    switch type
        case 'ePIE'
            out = conj(ker) .* in ./ max(max(abs(ker).^2));
        case 'tPIE'
            bias = abs(ker) ./ max(max(abs(ker)));
            fenzi = conj(ker) .* in ;
            fenmu = (abs(ker).^2 + 0.01);
            out = bias .* fenzi ./ fenmu;
        case 'none'
            out = conj(ker) .* in;
        otherwise 
            error()
    end
end