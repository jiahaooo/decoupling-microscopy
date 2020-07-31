clc
clear
global useGPU 
useGPU = 0;
global useGAT;
useGAT =  1;
global ADMM
ADMM = 0.5;
global HQS
HQS = ~ADMM;


run('matconvnet-1.0-beta25\matlab\vl_setupnn'); 
h = imreadstack('h488.tif');

sigma255 = 5;

f = imreadstack('simu_data\06_f.tif');
g = imfilter(floor(f),h,'conv','same');
g = imnoise(uint16(g),'poisson');
g = double(g) + 0.01*255*randn(size(f,1),size(f,2));
g(g<0) = 0;
g(g>255) = 255;
psnr_g = cal_psnr_max(f,g);
ssim_g = cal_ssim(f,g);

tic
[fhat,~] = CNNdeconv(g,h,sigma255,1.5); 
toc
fhat(fhat<0) = 0;
fhat(fhat>255) = 255;

psnr_deconv = cal_psnr_max(f,fhat);
ssim_deconv = cal_ssim(f,fhat);

imshow(uint8(cat(2,f,g,fhat)))