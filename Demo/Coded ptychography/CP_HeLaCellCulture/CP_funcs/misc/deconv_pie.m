function out = deconv_pie(in,ker,type)
    switch type
        case 'ePIE'
            out = conj(ker) .* in ./ max(max(abs(ker).^2));
        case 'tPIE'
            bias = abs(ker) ./ max(max(abs(ker)));
            fenzi = conj(ker) .* in ;
            fenmu = (abs(ker).^2 + 0.0001);
            out = bias .* fenzi ./ fenmu;
        case 'rPIE'
            bias = abs(ker) ./ max(max(abs(ker)));
            fenzi = conj(ker) .* in ;
            fenmu = (0.4*abs(ker).^2 + 0.6 * max(max(abs(ker).^2)));
            out = bias .* fenzi ./ fenmu;
        case 'none'
            out = conj(ker) .* in;
        otherwise 
            error()
    end
end