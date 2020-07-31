function z = cal_ssim(x,y)

xmax = max(x(:));

% 拒绝跑飘了的结果
% y(y<0) = 0.01;
% y(y>2*xmax) = 0.01;
 
if size(x,3)==1
    x = double(x);
    y = double(y); 
    [z, ~] = ssim_index(x,y);
else
    for ii = 1:size(x,3)
            x = double(x);
            y = double(y);
           [z, ~] = ssim_index(x,y);
           zz(ii) = z;
    end
        zz = mean(zz);
end