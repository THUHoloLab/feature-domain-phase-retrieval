%% parameters
lambda  = 0.523;          % wavelength
D_led   =  9 * 1000;          % LED distance
H_led   = 110 * 1000;          % LED distance to sample

k_lamuda = 2*pi/lambda; 

pixel_size  = 4;               % Camera pixel size
mag         = 4;               % Magnification
NA          = 0.1;             % Objective lens numerical aperture
M=pix;
N=pix;                           % Image size captured by CCD
D_pixel = pixel_size/mag;        % Image plane pixel size
kmax = NA * k_lamuda;               % Maximum wave number corresponding to the numerical aperture of the objective lens

%Magnification of the reconstructed image compared to the original image
MAGimg = 4;                     % ceil(1+2*D_pixel*3*D_led/sqrt((3*D_led)^2+h^2)/lamuda);%Magnification of the reconstructed image compared to the original image
MM = M*MAGimg;NN=N*MAGimg;      % Image size after reconstruction
Niter1 = 50;                    % Number of iterations
x= 0;
objdx=x*D_pixel;                % Location of the small area selected in the sample.As this area becomes larger, the vignetting becomes more pronounced
y= 0;
objdy=y*D_pixel;%
pratio = MAGimg;

%% spatial frequency
fx_CCD = (-pix/2:pix/2-1)/(pix * D_pixel);
df = fx_CCD(2)-fx_CCD(1);
[fx_CCD,fy_CCD] = meshgrid(fx_CCD);
CTF_CCD = (fx_CCD.^2+fy_CCD.^2)<(NA/lambda).^2;
Pupil0 = CTF_CCD;

Rcam = lambda / NA*mag / 2 /pixel_size;
RLED = NA*sqrt(D_led^2+H_led^2)/D_led;
Roverlap = 1/pi*(2*acos(1/2/RLED)-1/RLED*sqrt(1-(1/2/RLED)^2));

disp(['the overlapping rate is ',num2str(Rcam)]);
disp(['the overlapping rate is ',num2str(Roverlap)]);
plane_wave_org = zeros(led_total,2); %initial non-shifted plane wave

%% plane wave direction
count = 0;
for ring = 1:length(led_num)
    phi = linspace(0,2*pi,led_num(ring)+1) + rot_ang;
    for con = 1:led_num(ring)
        count = count + 1;
        r = D_led * (ring - 1);
        v = [0,0,H_led]-[r .* cos(phi(con)),r .* sin(phi(con)),0];
        v = v/norm(v);
        plane_wave_org(count,1) = v(2);
        plane_wave_org(count,2) = -v(1);
        
       
    end

end

count = 0;
dis = 0*1000;
for ring = 1:length(led_num)
    phi = linspace(0,2*pi,led_num(ring)+1) + rot_ang;
    for con = 1:led_num(ring)
        count = count + 1;
        r = D_led * (ring - 1);
        v = [0,0,H_led]-[r .* cos(phi(con)) + dis*randn(1),...
                         r .* sin(phi(con)) + dis*randn(1),0];
        v = v/norm(v);
        plane_wave(count,1) = v(2);
        plane_wave(count,2) = -v(1);
    end

end
% shifted_v = 0.01 * randn(led_total,2);
% plane_wave = plane_wave_org + shifted_v;

figure1 = figure('Color',[1 1 1]);
ax1 = axes();
hold(ax1,'on');
box(ax1,'on');
plot(plane_wave_org(:,1)/1,plane_wave_org(:,2)/1,'ok','markersize',5,'linewidth',1)
plot(plane_wave(:,1)/1,plane_wave(:,2)/1,'xr','markersize',8,'linewidth',1)

f_pos_set_true = zeros(led_total,4);
for con = 1:led_total
    fxc = round((MM+1)/2 + (plane_wave_org(con,1)/lambda)/df);
    fyc = round((MM+1)/2 + (plane_wave_org(con,2)/lambda)/df);
    
    fxl = round(fxc-(pix-1)/2);fxh=round(fxc+(pix-1)/2);
    fyl = round(fyc-(pix-1)/2);fyh=round(fyc+(pix-1)/2);
    f_pos_set_true(con,:) = [fxl,fxh,fyl,fyh];
end

f_pos_set_false = zeros(led_total,4);
for con = 1:led_total
    fxc = round((MM+1)/2 + (plane_wave(con,1)/lambda)/df);
    fyc = round((MM+1)/2 + (plane_wave(con,2)/lambda)/df);
    
    fxl = round(fxc-(pix-1)/2);fxh=round(fxc+(pix-1)/2);
    fyl = round(fyc-(pix-1)/2);fyh=round(fyc+(pix-1)/2);
    f_pos_set_false(con,:) = [fxl,fxh,fyl,fyh];
end


