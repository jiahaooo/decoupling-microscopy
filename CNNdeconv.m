function [output,z] = CNNdeconv(g,k,sigma255,gamma_para)

global useGAT
global useGPU
global ADMM

if useGAT
    alpha = 1;
else
    alpha = 0;
end

if nargin == 3
    gamma_para = 1;
end

load('models\modelgray_1.mat');

if gamma_para == 0 
    maxg = max(g(:));
    g = g./maxg;
else 
    maxg = max(g(:))/gamma_para;
    g = g./maxg;
end


sigma       = sigma255/255.0;
if ADMM
    lamda       = (sigma^2).*0.67;
    totalIter   = 25;
    modelSigma1 = 45;
    modelSigma2 = 15;
else % HQS
    lamda       = (sigma^2).*0.33;
    totalIter   = 20;
    modelSigma1 = 45;
    modelSigma2 = 15;
end
modelSigmaS = sqrt(logspace(log10(modelSigma1.^2),log10(modelSigma2.^2),totalIter)); 
ns          = min(25,max(ceil(modelSigmaS/2),1));
ns          = [ns(1)-1,ns]; 
rho         = lamda*(255^2)./(modelSigmaS.^2);

y = g;
u = zeros(size(g));
f = zeros(size(g));
fbar = zeros(size(g));
V = psf2otf(k,[size(y,1),size(y,2)]);
denominator = abs(V).^2;
upperleft   = conj(V).*fft2(y);
z = imfilter(single(y),ones(5,5)./25,'same','circular'); 

if useGPU
    z           = gpuArray(z);
    f           = gpuArray(f);
    u           = gpuArray(u);
    fbar           = gpuArray(fbar);
    upperleft   = gpuArray(upperleft);
    denominator = gpuArray(denominator);
end

for itern = 1:totalIter
%%% step 1
% itern
rho1 = rho(itern);
% rho = lamda*255^2/(modelSigmaS(itern)^2);
f = real(ifft2((upperleft + rho1*fft2(z-u))./(denominator + rho1)));
if ns(itern+1)~=ns(itern)
    [net] = loadmodel(modelSigmaS(itern),CNNdenoiser);
    net = vl_simplenn_tidy(net);
    
%     net.layers = net.layers(1:end-1); % reduce loss layer in test
%     net = vl_simplenn_tidy(net);
    
    if useGPU
        net = vl_simplenn_move(net, 'gpu');
    end
end
% % overcome ringings
% % only for hqs methods & may damage resolution
% % overcome_ringings = fspecial('gaussian',15,0.5);
% % f = imfilter(f,overcome_ringings,'conv','same');
%%% step 2
% GAT
fbar = f+u;
if useGAT
    fbar = fbar.* maxg;
    fbar = gat(fbar,alpha,0,0);
    maxfbar = max(fbar(:));
    fbar = fbar./maxfbar;
elseif gamma_para ==0
   maxfbar = max(fbar(:)); 
   fbar = fbar./maxfbar;
elseif gamma_para~=0 
    maxfbar = 1.0;
    fbar = fbar * maxfbar;
end
% denoising
z = fbar;
res = vl_simplenn(net, single(z) ,[],[],'conserveMemory',true,'mode','test');
residual = res(end).x;
z = (z) - residual;
% iGAT
if useGAT
    z = z.*maxfbar;
    z = igat(z,alpha,0,0);
    z = z./ maxg;
else
   z = z.*maxfbar;
end
%%% step 3
if ADMM
    u = u + single(ADMM) * ( f - z ) ; 
else % HQS
   	u = 0;
end
% imshow(abs(u),[]);
end

if useGPU
    z = gather(z);
end

z(z<0)=0;
% z(z>1)=1;
output = z.*maxg;