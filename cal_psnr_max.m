function psnr = cal_psnr_max(a,b)
% fengzhi = max(max(max(max(a))),max(max(max(b))));
a = double(a);
b = double(b);
% [a1,a2]=size(a);
if size(a,3)==1
    fengzhi = max(max((a)));
    MSE = mean(mean((double(a)-double(b)).^2));
    psnr = 10*log(fengzhi^2/MSE)/log(10);
else
    for ii = 1:size(a,3)
        fengzhi = max(max(a(:,:,ii)));
        MSE = mean(mean((double(a(:,:,ii))-double(b(:,:,ii))).^2));
        psnr_(ii) = 10*log(fengzhi^2/MSE)/log(10);
    end
        psnr = mean(psnr_);
end
