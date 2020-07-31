clc
clear
global useGPU 
useGPU = 0;
global useGAT;
useGAT =  0;
global ADMM
ADMM = 1;
global HQS
HQS = ~ADMM;

run('matconvnet-1.0-beta25\matlab\vl_setupnn'); 

h = imreadstack('f:\tool\h488.tif');

sigma255 = 4;
gamma_para = 0; % 0.7-1.5 if useGAT else 0

g = imreadstack('tirf_data\Lifeact-EGFP_HUVEC_488.tif');
cutmin = min(g(:));
g = g - cutmin;
g(g<0) = 0;

[sizefx,sizefy] = size(g);
sizefnew = max(sizefx,sizefy)+20;
fnew = zeros(sizefnew,sizefnew);   
for iiii = 1:10
    fnew(1+floor((sizefnew-sizefx)/2):sizefx+floor((sizefnew-sizefx)/2), ...
        1+floor((sizefnew-sizefy)/2):sizefy+floor((sizefnew-sizefy)/2)) = g;
    fnew = imfilter(fnew,h,'conv','circular');
end

fnew(1+floor((sizefnew-sizefx)/2):sizefx+floor((sizefnew-sizefx)/2), ...
    1+floor((sizefnew-sizefy)/2):sizefy+floor((sizefnew-sizefy)/2)) = g;
gg = fnew;
clear fnew

tic
[fhat_big,~] = CNNdeconv(gg,h,sigma255,gamma_para); 
toc
fhat = fhat_big(1+floor((sizefnew-sizefx)/2):sizefx+floor((sizefnew-sizefx)/2), ...
1+floor((sizefnew-sizefy)/2):sizefy+floor((sizefnew-sizefy)/2));
fhat(fhat<0) = 0;

imshow((cat(2,g,fhat))/350)